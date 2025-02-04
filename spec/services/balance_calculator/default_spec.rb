# frozen_string_literal: true

require_relative '../../../app/services/balance_calculator/default'

RSpec.describe BalanceCalculator::Default do
  let(:deposit10) { instance_double('Event', type: :deposit, amount: 10, destination: 1) }
  let(:withdraw1) { instance_double('Event', type: :withdraw, amount: 1, origin: 1) }
  let(:transfer2) { instance_double('Event', type: :transfer, amount: 2, origin: 1, destination: 2) }

  context 'predefined balance of 50' do
    let(:deposits) { [deposit10] * 5 }

    it 'calculates the balance correctly' do
      balance = described_class.calculate(1, deposits)

      expect(balance).to eq(50)
    end

    context 'when there is some withdrawls' do
      before do
        deposits.concat([withdraw1] * 10)
      end

      it 'decrease the balance by 10' do
        balance = described_class.calculate(1, deposits)

        expect(balance).to eq(40)
      end
    end

    context 'when there is some transfers' do
      before do
        deposits.concat([transfer2] * 5)
      end

      it 'decreases the balance by 10' do
        balance = described_class.calculate(1, deposits)

        expect(balance).to eq(40)
      end
    end
  end
end
