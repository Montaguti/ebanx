# frozen_string_literal: true

require_relative '../../app/models/account'
require_relative '../../app/storage/in_memory_account_repository'

RSpec.describe 'AccountRepository Integration' do
  let(:repo) { InMemoryAccountRepository.instance }
  let(:account) { Account.new(1) }

  context '#find_or_create_account' do
    it 'returns an Account' do
      expect(repo.find_or_create_account(1)).to be_instance_of(Account)
    end
  end
end
