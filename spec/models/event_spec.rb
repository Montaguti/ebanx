# frozen_string_literal: true

require_relative '../../app/models/event'
require_relative '../../app/models/event/errors'

RSpec.describe Event do
  let(:event_params) do
    {
      type: 'deposit',
      amount: 10.0,
      destination: 1,
      origin: 1
    }
  end

  context 'while initilizing' do
    it 'returns an instance of Event' do
      expect(Event.new(**event_params)).to be_an_instance_of(Event)
    end

    describe 'when :amount is missing' do
      it 'raises an error' do
        params = event_params.except(:amount)

        expect do
          Event.new(**params)
        end.to raise_error(ArgumentError)
      end
    end

    describe 'when :type is missing' do
      it 'raises an error' do
        params = event_params.except(:type)

        expect do
          Event.new(**params)
        end.to raise_error(ArgumentError)
      end
    end

    describe 'when invalid :type is provided' do
      it 'raises an error' do
        event_params[:type] = 'foo'

        expect do
          Event.new(**event_params)
        end.to raise_error(Event::InvalidTypeError)
      end
    end
  end
end
