# frozen_string_literal: true

require_relative './balance_calculator/default'
require_relative './event_processor'

# AccountService interface wich depends storage mechanism
class AccountService
  def initialize(storage, event_processor: EventProcessor, calculator: BalanceCalculator::Default)
    @storage = storage
    @event_processor = event_processor
    @calculator = calculator
  end

  def get_balance(account_id, events)
    account = @storage.find_account(account_id)
    return unless account

    @calculator.calculate(account_id, events)
  end

  def handle_event(event)
    @event_processor.process(@storage, event, calculator: @calculator).tap do |accounts|
      accounts.compact.each do |account|
        @storage.save_account(account)
      end
    end
  end
end
