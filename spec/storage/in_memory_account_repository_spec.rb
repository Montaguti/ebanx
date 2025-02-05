# frozen_string_literal: true

class DummyAccount
  attr_reader :id, :events

  def initialize(id)
    @id = id
    @events = []
  end

  class NotFoundError < StandardError; end
end

require_relative '../../app/storage/in_memory_account_repository'

RSpec.describe InMemoryAccountRepository do
  let(:account_stub) { instance_double('Account', id: '1', events: []) }
  let(:account2_stub) { instance_double('Account', id: '2', events: []) }

  before do
    stub_const('Account', DummyAccount)
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
      it 'raises Account::NotFoundError for any query' do
        expect { repo.find_account(123) }.to raise_error(Account::NotFoundError)
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
    context 'when account doesn\'t exist' do
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
