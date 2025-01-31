# frozen_string_literal: true

class Account
  # Account::InsufficientFundsError
  class InsufficientFundsError < StandardError
    def initialize(msg = 'Insufficient funds for this operation')
      super
    end
  end

  # Account::AccountNotFoundError
  class AccountNotFoundError < StandardError
    def initialize(msg = 'Account not found')
      super
    end
  end
end
