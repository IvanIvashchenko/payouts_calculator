require 'rails_helper'

RSpec.describe MonthlyFees::Create, type: :service do
  describe '#execute' do
    subject(:execute) { MonthlyFees::Create.new.call }

    context 'when there is no merchants in system' do
      it { expect { execute }.not_to change(MonthlyFee, :count) }
    end

    context 'when there is no suitable merchants for check' do
      let(:merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: Date.today.next_month,
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end

      it { expect { execute }.not_to change(MonthlyFee, :count) }
    end

    context 'when all merchants do have more than min payouts fees' do
      let(:daily_merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: '2023-02-02',
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end
      let(:weekly_merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant2@gmail.com',
          live_on: '2022-12-29',
          payout_frequency: 'weekly',
          min_monthly_fee: 20
        )
      end

      before do
        Payout.create(
          merchant: daily_merchant,
          total_amount: 200,
          total_fee: 20,
          payout_date: Date.today.prev_month
        )
        Payout.create(
          merchant: weekly_merchant,
          total_amount: 300,
          total_fee: 10,
          payout_date: Date.today.prev_month
        )
        Payout.create(
          merchant: weekly_merchant,
          total_amount: 450,
          total_fee: 14,
          payout_date: Date.today.prev_month
        )
      end

      it { expect { execute }.not_to change(MonthlyFee, :count) }
    end

    context 'when there is no payouts for the merchant for previous month' do
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
          total_fee: 10,
          payout_date: Date.today
        )
        Payout.create(
          merchant:,
          total_amount: 200,
          total_fee: 10,
          payout_date: 3.months.ago
        )
      end

      it { expect { execute }.to change(MonthlyFee, :count).from(0).to(1) }

      it 'creates monthly fee with minimum monthly fee value' do
        execute

        expect(MonthlyFee.find_by(merchant_id: merchant.id).amount).to eq(15.0)
      end
    end
    context 'when some merchants generate less than min payouts fees' do
      let(:daily_merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: '2023-02-02',
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end
      let(:weekly_merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant2@gmail.com',
          live_on: '2022-12-29',
          payout_frequency: 'weekly',
          min_monthly_fee: 20
        )
      end

      before do
        Payout.create(
          merchant: daily_merchant,
          total_amount: 200,
          total_fee: 10,
          payout_date: Date.today.prev_month
        )
        Payout.create(
          merchant: weekly_merchant,
          total_amount: 300,
          total_fee: 10,
          payout_date: Date.today.prev_month
        )
        Payout.create(
          merchant: weekly_merchant,
          total_amount: 450,
          total_fee: 4,
          payout_date: Date.today.prev_month
        )
      end

      it { expect { execute }.to change(MonthlyFee, :count).from(0).to(2) }

      it 'creates monthly fees with values up to min fee' do
        execute

        aggregate_failures do
          expect(MonthlyFee.find_by(merchant_id: daily_merchant.id).amount).to eq(5.0)
          expect(MonthlyFee.find_by(merchant_id: weekly_merchant.id).amount).to eq(6.0)
        end
      end
    end
  end
end

