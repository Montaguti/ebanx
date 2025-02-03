# frozen_string_literal: true

require_relative '../../app/storage/in_memory_account_repository'

describe InMemoryAccountRepository do
  let(:account_stub) { instance_double('Account', id: 1, events: []) }

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
end
