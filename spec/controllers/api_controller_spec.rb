# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/controllers/api_controller'

RSpec.describe ApiController, type: :request do
  include Rack::Test::Methods

  def app
    ApiController
  end

  let(:account_service) { instance_double('AccountService') }

  before do
    allow_any_instance_of(ApiController).to receive(:account_service).and_return(account_service)
    allow(account_service).to receive(:handle_event)
  end

  describe 'GET /balance' do
    context 'when the account exists' do
      before do
        allow(account_service).to receive(:get_balance).with('123').and_return(100)
      end

      it 'returns 200 and the balance' do
        get '/balance', account_id: '123'

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq '100'
      end
    end

    context 'when the account does not exist' do
      before do
        allow(account_service).to receive(:get_balance).with('999').and_raise(Account::NotFoundError)
      end

      it 'returns 404 and a body of "0"' do
        get '/balance', account_id: '999'

        expect(last_response.status).to eq 404
        expect(last_response.body).to eq '0'
      end
    end
  end

  describe 'POST /event' do
    context 'when a deposit event is sent' do
      let(:event) { { type: 'deposit', destination: '100', amount: 10 } }
      let(:response_json) do
        {
          'destination' => { 'id' => '100', 'balance' => 20 }
        }
      end

      before do
        allow(account_service).to receive(:get_balance).with('100').and_return(20)
      end

      it 'returns status 201 and the correct JSON response' do
        post '/event', event.to_json, { 'CONTENT_TYPE' => 'application/json' }

        resp = last_response
        json = JSON.parse(resp.body)

        expect(resp.status).to eq(201)
        expect(json).to eq(response_json)
      end
    end

    context 'when a withdraw event is sent' do
      let(:event) { { type: 'withdraw', origin: '100', amount: 5 } }
      let(:response_json) do
        {
          'origin' => { 'id' => '100', 'balance' => 15 }
        }
      end

      before do
        allow(account_service).to receive(:get_balance).with('100').and_return(15)
      end

      it 'returns status 201 and the correct JSON response' do
        post '/event', event.to_json, { 'CONTENT_TYPE' => 'application/json' }

        resp = last_response
        json = JSON.parse(resp.body)

        expect(resp.status).to eq(201)
        expect(json).to eq(response_json)
      end
    end

    context 'when a transfer event is sent' do
      let(:event) { { type: 'transfer', origin: '100', destination: '300', amount: 15 } }
      let(:response_json) do
        {
          'origin' => { 'id' => '100', 'balance' => 0 },
          'destination' => { 'id' => '300', 'balance' => 15 }
        }
      end

      before do
        allow(account_service).to receive(:get_balance).with('100').and_return(0)
        allow(account_service).to receive(:get_balance).with('300').and_return(15)
      end

      it 'returns status 201 and the correct JSON response' do
        post '/event', event.to_json, { 'CONTENT_TYPE' => 'application/json' }

        resp = last_response
        json = JSON.parse(resp.body)

        expect(resp.status).to eq(201)
        expect(json).to eq(response_json)
      end
    end
  end
end
