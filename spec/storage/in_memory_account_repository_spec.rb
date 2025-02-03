# frozen_string_literal: true

require_relative '../../app/storage/in_memory_account_repository'

describe InMemoryAccountRepository do
  let(:account_stub) { instance_double('Account', id: 1, events: []) }
  let(:account2_stub) { instance_double('Account', id: 2, events: []) }
  let(:dummy_account_class) do
    Class.new do
      attr_reader :id

      def initialize(id)
        @id = id
      end
    end
  end

  before do
    stub_const('Account', dummy_account_class)
  end

  subject(:repo) { InMemoryAccountRepository.instance }

  it { is_expected.to be_an_instance_of(InMemoryAccountRepository) }

  describe 'AccountRepository interface' do
    it { is_expected.to respond_to(:find_account) }
    it { is_expected.to respond_to(:find_or_create_account) }
    it { is_expected.to respond_to(:save_account) }
  end

  describe 'Singleton' do
    let(:instance2) { InMemoryAccountRepository.instance }

    it { is_expected.to equal(instance2) }
  end

  describe '#find_account' do
    context 'without stored account' do
      it 'returns nil for any query' do
        expect(repo.find_account(123)).to be_nil
      end
    end

    context 'with stored accounts' do
      before do
        repo.save_account(account_stub)
      end

      it 'returns an account for an existing id' do
        expect(repo.find_account(account_stub.id)).to eq(account_stub)
      end
    end
  end

  describe '#find_or_create_account' do
    context 'when account doesn\'t exists' do
      it 'returns a new account' do
        expect(
          repo.find_or_create_account(account2_stub.id)
        ).to be_instance_of(Account)
      end
    end
  end

  describe '#save_account' do
    let(:event) { { type: 'deposit', amount: 10, destination: account_stub.id } }

    it 'overrides an existing account' do
      account_stub.events << event
      repo.save_account(account_stub)

      expect(
        repo.find_account(account_stub.id).events
      ).to include(event)
    end
  end
end
