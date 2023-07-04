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
  end
end
