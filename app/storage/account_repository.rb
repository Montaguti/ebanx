# frozen_string_literal: true

# Account persistence abstraction
module AccountRepository
  def find_account(account_id)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def find_or_create_account(account_id)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def save_account(account)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
