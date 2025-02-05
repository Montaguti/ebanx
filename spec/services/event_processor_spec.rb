# frozen_string_literal: true

require_relative '../../app/services/event_processor'

RSpec.describe EventProcessor do
  let(:storage) { instance_double('AccountRepository') }
  let(:account) { instance_double('Account', id: 1, events: []) }
  let(:calculator) { class_double('BalanceCalculator::Default') }
  let(:origin) { instance_double('Account', id: 3, events: []) }

  before do
    allow(storage).to receive(:find_account).with(origin.id).and_return(nil)
    allow(storage).to receive(:find_account).with(account.id).and_return(account)
    allow(storage).to receive(:find_or_create_account).with(account.id).and_return(account)
    allow(account).to receive(:add_event)
  end

  describe '#process' do
    context 'with :deposit event' do
      let(:event) { instance_double('Event', type: :deposit, destination: account.id, amount: 10) }

      it 'searchs the account and stores the event' do
        expect(storage).to receive(:find_or_create_account).with(event.destination)
        expect(account).to receive(:add_event).with(event)

        result = described_class.process(storage, event)
        expect(result).to eq([account])
      end
    end

    context 'with :transfer event' do
      let(:event) do
        instance_double('Event', type: :transfer, destination: account.id, origin: origin.id, amount: 10)
      end

      context 'when the origin doesn\'t exists' do
        it 'raises Account::NotFoundError' do
          expect { described_class.process(storage, event) }.to raise_error(Account::NotFoundError)
        end
      end

      context 'when the origin doesn\'t has funds' do
        before do
          allow(storage).to receive(:find_account).with(origin.id).and_return(origin)
        end

        it 'rasies Account::InsufficientFundsError' do
          expect do
            described_class.process(storage, event)
          end.to raise_error(Account::InsufficientFundsError)
        end
      end

      context 'with sufficient funds' do
        before do
          allow(calculator).to receive(:calculate).with(origin).and_return(20)
        end

        it 'trasnfer funds between accounts' do
          expect(storage).to receive(:find_account).with(origin.id).and_return(origin)
          expect(storage).to receive(:find_or_create_account).with(account.id)
          expect(origin).to receive(:add_event).with(event)
          expect(account).to receive(:add_event).with(event)

          described_class.process(storage, event, calculator: calculator)
        end
      end
    end

    context 'with :withdraw event' do
      let(:event) { instance_double('Event', type: :withdraw, origin: origin.id, amount: 10) }

      context 'when account doesn\'t exists' do
        it 'raises Account::NotFoundError' do
          expect { described_class.process(storage, event) }.to raise_error(Account::NotFoundError)
        end
      end

      context 'when account doesn\'t has funds' do
        before do
          allow(storage).to receive(:find_account).and_return(origin)
        end

        it 'raises Account::InsufficientFundsError' do
          expect { described_class.process(storage, event) }.to raise_error(Account::InsufficientFundsError)
        end
      end

      context 'with sufficient funds' do
        before do
          allow(storage).to receive(:find_account).and_return(origin)
          allow(calculator).to receive(:calculate).with(origin).and_return(100)
        end

        it 'add a subtraction event to account' do
          expect(origin).to receive(:add_event)

          described_class.process(storage, event, calculator: calculator)
        end
      end
    end
  end
end
