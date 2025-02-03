# frozen_string_literal: true

require 'singleton'
require_relative './account_repository'
require_relative '../models/account'

# InMemoryAccountRepository
# implements AccountRepository interface
# stores data as a singleton
class InMemoryAccountRepository
  include Singleton
  include AccountRepository

  def initialize
    @accounts = {}
    @mutex = Mutex.new
    super
  end

  def find_account(id)
    @accounts[id.to_s]
  end

  def find_or_create_account(id)
    @mutex.synchronize do
      @accounts[id.to_s] ||= Account.new(id)
    end
  end

  def save_account(account)
    @mutex.synchronize do
      @accounts[account.id.to_s] = account
    end
  end
end
