# frozen_string_literal: true

require 'json'
require 'sinatra'

require_relative '../services/account_service'
require_relative '../storage/in_memory_account_repository'

# ApiController
class ApiController < Sinatra::Base
  configure do
    set :environment, :production

    set :views, File.expand_path('../views', __dir__)
  end

  post '/reset' do
    InMemoryAccountRepository.instance.reset

    halt 200, 'OK'
  end

  get '/balance' do
    balance = account_service.get_balance(params['account_id'])
    balance_response(balance)
  rescue StandardError => e
    handle_error(e)
  end

  post '/event' do
    content_type :json

    @event = event_json(request)
    @account_service = account_service

    account_service.handle_event(@event)

    status 201
    erb :'event.json', layout: false
  rescue StandardError => e
    handle_error(e)
  end

  private

  def account_service
    @account_service ||= AccountService.new(InMemoryAccountRepository.instance)
  end

  def balance_response(balance)
    halt 200, balance.to_s
  end

  def event_json(req)
    data = req.body.read
    JSON.parse(data, symbolize_names: true)
  end

  def handle_error(error)
    case error
    when Account::NotFoundError
      halt 404, '0'
    else
      halt 500, error.message
    end
  end
end
