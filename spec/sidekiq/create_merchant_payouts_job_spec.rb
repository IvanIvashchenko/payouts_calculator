require 'rails_helper'

RSpec.describe CreateMerchantPayoutsJob, type: :job do
  describe '#perform' do
    subject(:perform) { CreateMerchantPayoutsJob.new.perform(merchant.id) }

    let(:payouts_service) { instance_double(Payouts::Create) }
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
      allow(Payouts::Create).to receive(:new).with(merchant.id, Date.today - 1.day).and_return(payouts_service)
      allow(payouts_service).to receive(:call)
    end

    it 'starts payout creation process for the previous day' do
      perform

      expect(payouts_service).to have_received(:call)
    end
  end
end
