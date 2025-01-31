# frozen_string_literal: true

require_relative '../../app/models/account'
require_relative '../../app/models/account/errors'

RSpec.describe Account do
  let(:account_id) { 1 }

  context 'while initilizing' do
    it 'returns an instance of Account' do
      expect(Account.new(account_id)).to be_an_instance_of(Account)
    end
  end

  context 'after initialized' do
    let(:account) { Account.new(1) }

    it 'has an events array' do
      expect(account.events).to eq([])
    end
  end
end
