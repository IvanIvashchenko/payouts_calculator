require 'rails_helper'

RSpec.describe Payouts::Create, type: :service do
  describe '#execute' do
    subject(:execute) { Payouts::Create.new(merchant.id, Date.parse('2023-06-01')).call }

    let(:merchant) do
      Merchant.create(
        reference: SecureRandom.uuid,
        email: 'merchant1@gmail.com',
        live_on: '2023-01-01',
        payout_frequency: 'daily',
        min_monthly_fee: 15
      )
    end

    context 'when there is no orders in system' do
      it { expect { execute }.not_to change(Payout, :count) }
    end

    context 'when there is no suitable orders for payout' do
      before do
        Order.create(
          merchant:,
          amount: 20,
          created_by_merchant_at: '2023-05-01'
        )
      end

      it { expect { execute }.not_to change(Payout, :count) }
    end

    context 'when there are some suitable orders for daily merchant' do
      let(:merchant) do
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
          live_on: '2022-12-29', # Thursday
          payout_frequency: 'weekly',
          min_monthly_fee: 15
        )
      end

      before do
        Order.create(
          merchant:,
          amount: 20,
          created_by_merchant_at: '2023-05-01'
        )
        Order.create(
          merchant:,
          amount: 30,
          created_by_merchant_at: '2023-06-01'
        )
        Order.create(
          merchant: weekly_merchant,
          amount: 10,
          created_by_merchant_at: '2023-05-31'
        )
        Order.create(
          merchant: weekly_merchant,
          amount: 100,
          created_by_merchant_at: '2023-05-23'
        )
      end

      it { expect { execute }.to change(Payout, :count).from(0).to(1) }

      it 'creates payout for daily merchant for the corresponding day' do
        execute

        payouts = Payout.where(merchant_id: merchant.id)
        aggregate_failures do
          expect(payouts.size).to eq(1)
          expect(payouts.first.payout_date.to_s).to eq('2023-06-01')
          expect(payouts.first.total_amount).to eq(30)
        end
      end

      it 'updates related orders by created payout ids' do
        execute

        aggregate_failures do
          expect(Order.where(payout_id: nil).count).to eq(3)
          expect(Order.pluck(:payout_id).compact).to match_array(Payout.pluck(:id))
        end
      end
    end

    context 'when there are some suitable orders for weekly merchant' do
      let(:daily_merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant1@gmail.com',
          live_on: '2023-02-02',
          payout_frequency: 'daily',
          min_monthly_fee: 15
        )
      end
      let(:merchant) do
        Merchant.create(
          reference: SecureRandom.uuid,
          email: 'merchant2@gmail.com',
          live_on: '2022-12-29', # Thursday
          payout_frequency: 'weekly',
          min_monthly_fee: 15
        )
      end

      before do
        Order.create(
          merchant: daily_merchant,
          amount: 20,
          created_by_merchant_at: '2023-05-01'
        )
        Order.create(
          merchant: daily_merchant,
          amount: 30,
          created_by_merchant_at: '2023-06-01'
        )
        Order.create(
          merchant:,
          amount: 10,
          created_by_merchant_at: '2023-05-31'
        )
        Order.create(
          merchant:,
          amount: 100,
          created_by_merchant_at: '2023-05-23'
        )
      end

      it { expect { execute }.to change(Payout, :count).from(0).to(1) }

      it 'creates payout for weekly merchant for the corresponding week' do
        execute

        payouts = Payout.where(merchant_id: merchant.id)
        aggregate_failures do
          expect(payouts.size).to eq(1)
          expect(payouts.first.payout_date.to_s).to eq('2023-06-01')
          expect(payouts.first.total_amount).to eq(10)
        end
      end

      it 'updates related orders by created payout ids' do
        execute

        aggregate_failures do
          expect(Order.where(payout_id: nil).count).to eq(3)
          expect(Order.pluck(:payout_id).compact).to match_array(Payout.pluck(:id))
        end
      end
    end

    context 'when there are orders with different applicable fees' do
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
        Order.create(
          merchant: merchant,
          amount: 40,
          created_by_merchant_at: '2023-06-01'
        )
        Order.create(
          merchant: merchant,
          amount: 100,
          created_by_merchant_at: '2023-06-01'
        )
        Order.create(
          merchant: merchant,
          amount: 400,
          created_by_merchant_at: '2023-06-01'
        )
        end

      it 'calculates fees related to orders amount' do
        execute

        expect(Payout.first.total_fee).to eq(4.75)
      end
    end
  end
end

