# frozen_string_literal: true

require_relative '../models/account'
require_relative '../models/account/errors'
require_relative '../models/event'
require_relative './balance_calculator/default'

# EventProcessor
class EventProcessor
  STRATEGIES = {
    deposit: lambda { |storage, event, _calculator|
      account = storage.find_or_create_account(event.destination)

      account.add_event(event)

      [account]
    },
    withdraw: lambda { |storage, event, calculator|
      account = storage.find_account(event.origin)
      raise Account::NotFoundError unless account

      balance = calculator.calculate(account)
      raise Account::InsufficientFundsError if balance < event.amount

      account.add_event(event)

      [account]
    },
    transfer: lambda { |storage, event, calculator|
      origin = storage.find_account(event.origin)
      raise Account::NotFoundError unless origin

      balance = calculator.calculate(origin)
      raise Account::InsufficientFundsError if balance < event.amount

      destination = storage.find_or_create_account(event.destination)

      origin.add_event(event)
      destination.add_event(event)

      [origin, destination]
    }
  }.freeze

  def self.process(storage, event, calculator: BalanceCalculator::Default)
    strategy = STRATEGIES[event.type]
    strategy.call(storage, event, calculator)
  end
end
