require 'rails_helper'

RSpec.describe CreatePayoutsJob, type: :job do
  describe '#perform' do
    subject(:perform) { CreatePayoutsJob.new.perform }

    let!(:merchant) do
      Merchant.create(
        reference: SecureRandom.uuid,
        email: 'merchant1@gmail.com',
        live_on: '2023-01-01',
        payout_frequency: 'daily',
        min_monthly_fee: 15
      )
    end

    before do
      allow(CreateMerchantPayoutsJob).to receive(:perform_async)
    end

    it 'starts payout creation process for the merchant' do
      perform

      expect(CreateMerchantPayoutsJob).to have_received(:perform_async).once.with(merchant.id)
    end

    context 'when there is a first day of the month' do
      let(:monthly_fees_service) { instance_double(MonthlyFees::Create) }

      before do
        travel_to Time.zone.local(2023, 06, 01)
        allow(MonthlyFees::Create).to receive(:new).and_return(monthly_fees_service)
        allow(monthly_fees_service).to receive(:call)
      end

      after do
        travel_back
      end

      it 'starts monthly fees creation process for the previous month' do
        perform

        expect(monthly_fees_service).to have_received(:call)
      end
    end

    context 'when there is any other day of the month except first' do
      let(:monthly_fees_service) { instance_double(MonthlyFees::Create) }

      before do
        travel_to Time.zone.local(2023, 06, 05)
        allow(MonthlyFees::Create).to receive(:new).and_return(monthly_fees_service)
        allow(monthly_fees_service).to receive(:call)
      end

      after do
        travel_back
      end

      it 'does not start monthly fees creation process for the previous month' do
        perform

        expect(monthly_fees_service).not_to have_received(:call)
      end
    end
  end
end
