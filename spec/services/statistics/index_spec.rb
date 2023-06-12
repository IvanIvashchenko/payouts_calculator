require 'rails_helper'

RSpec.describe Statistics::Index, type: :service do
  describe '#result' do
    subject(:result) { Statistics::Index.new('2023-01-01', '2023-12-31').call }

    shared_examples 'stats without values' do
      it 'returns result for the given year' do
        aggregate_failures do
          expect(result.size).to eq(1)
          expect(result.first[:year]).to eq(2023)
        end
      end

      it 'returns empty values for payouts and fees stats' do
        aggregate_failures do
          expect(result.first[:payouts_number]).to be_nil
          expect(result.first[:payouts_sum]).to be_nil
          expect(result.first[:payouts_fees_sum]).to be_nil
          expect(result.first[:monthly_fees_number]).to be_nil
          expect(result.first[:monthly_fees_sum]).to be_nil
        end
      end
    end

    context 'when there is no payouts and fees in system' do
      it_behaves_like 'stats without values'
    end

    context 'when there is no payouts and fees for the given year' do
      let(:merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: '2023-02-02',
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end

      before do
        Payout.create(
          merchant:,
          total_amount: 200,
          total_fee: 20,
          payout_date: '2022-01-01'
        )
        Payout.create(
          merchant:,
          total_amount: 300,
          total_fee: 10,
          payout_date: '2022-02-02'
        )
        MonthlyFee.create(
          merchant:,
          paid_for: '2022-02-02',
          amount: 5
        )
      end

      it_behaves_like 'stats without values'
    end

    context 'when there are some payouts and fees for the given year' do
      let(:merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: '2023-02-02',
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end

      before do
        Payout.create(
          merchant:,
          total_amount: 200,
          total_fee: 20,
          payout_date: '2023-01-01'
        )
        Payout.create(
          merchant:,
          total_amount: 300,
          total_fee: 10,
          payout_date: '2023-02-02'
        )
        Payout.create(
          merchant:,
          total_amount: 55.5,
          total_fee: 11.83,
          payout_date: '2023-02-02'
        )
        MonthlyFee.create(
          merchant:,
          paid_for: '2023-03-03',
          amount: 5
        )
        MonthlyFee.create(
          merchant:,
          paid_for: '2023-04-04',
          amount: 13.3
        )
      end

      it 'returns the corresponding values for payouts and fees' do
        aggregate_failures do
          expect(result.first[:payouts_number]).to eq(3)
          expect(result.first[:payouts_sum]).to eq(555.5)
          expect(result.first[:payouts_fees_sum]).to eq(41.83)
          expect(result.first[:monthly_fees_number]).to eq(2)
          expect(result.first[:monthly_fees_sum]).to eq(18.3)
        end
      end
    end
  end
end
