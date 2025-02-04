# frozen_string_literal: true

require_relative '../../app/services/account_service'

RSpec.describe AccountService do
  let(:storage) { instance_double('AccountRepository') }
  let(:event_processor) { class_double('EventProcessor') }
  let(:calculator) { class_double('BalanceCalculator::Default') }

  let(:event_amount) { 10 }
  let(:event) { instance_double('Event', type: :deposit, destination: 1, amount: event_amount) }
  let(:account) { instance_double('Account', id: 1, events: []) }

  subject(:service) { described_class.new(storage, event_processor: event_processor, calculator: calculator) }

  describe '#handle_event' do
    context 'when event processing succeeds' do
      before do
        allow(event_processor).to receive(:process)
          .with(storage, event, calculator: calculator)
          .and_return([account])
        allow(storage).to receive(:save_account).with(account)
      end

      it 'processes the event and saves the account' do
        result = service.handle_event(event)

        expect(result).to eq([account])
        expect(event_processor).to have_received(:process).with(storage, event, calculator: calculator)
        expect(storage).to have_received(:save_account).with(account)
      end
    end

    context 'when event processing fails' do
      before do
        allow(event_processor).to receive(:process)
          .and_raise(Account::NotFoundError)
      end

      it 'propagates errors' do
        expect { service.handle_event(event) }.to raise_error(Account::NotFoundError)
      end
    end
  end

  describe '#get_balance' do
    let(:account2) { instance_double('Account', id: 2, events: [event]) }

    context 'when account exists' do
      before do
        allow(storage).to receive(:find_account).with(account2.id).and_return(account2)
        allow(calculator).to receive(:calculate).with(account2.id, account2.events).and_return(event_amount)
      end

      it 'returns calculated balance' do
        balance = service.get_balance(account2.id, account2.events)

        expect(balance).to eq(event_amount)
      end
    end

    context 'when account doesn\'t exists' do
      before do
        allow(storage).to receive(:find_account).and_return(nil)
      end

      it 'returns nil' do
        balance = service.get_balance(account2.id, account2.events)

        expect(balance).to be_nil
      end
    end
  end
end
