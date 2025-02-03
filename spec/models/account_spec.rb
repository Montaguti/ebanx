# frozen_string_literal: true

require_relative '../../app/models/account'
require_relative '../../app/models/account/errors'

RSpec.describe Account do
  let(:account_id) { 1 }

  describe 'methods' do
    subject { Account.new(0) }
    it { is_expected.to respond_to(:add_event) }
  end

  context 'while initilizing' do
    it 'returns an instance of Account' do
      expect(Account.new(account_id)).to be_an_instance_of(Account)
    end
  end

  context 'after initialized' do
    let(:account) { Account.new(1) }

    it 'has an empty Event array' do
      expect(account.events).to eq([])
    end

    describe 'when adding an event' do
      before do
        account.add_event({ type: 'deposit', amount: 100, destination: 1 })
      end

      it 'increases the events.count' do
        expect(account.events.count).to eq(1)
      end
    end
  end
end
