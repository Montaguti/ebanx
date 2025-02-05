# frozen_string_literal: true

require_relative './balance_calculator/default'
require_relative './event_processor'
require_relative '../models/event'

# AccountService
class AccountService
  def initialize(storage, event_klass: Event, event_processor: EventProcessor, calculator: BalanceCalculator::Default)
    @storage = storage
    @event_processor = event_processor
    @calculator = calculator
    @event_klass = event_klass
  end

  def get_balance(account_id)
    account = @storage.find_account(account_id)
    return unless account

    @calculator.calculate(account)
  end

  def handle_event(event_params)
    event = @event_klass.new(**event_params)

    @event_processor.process(@storage, event, calculator: @calculator).tap do |accounts|
      accounts.compact.each do |account|
        @storage.save_account(account)
      end
    end
  end
end
