require 'rails_helper'

RSpec.describe CreatePayoutsJob, type: :job do
  describe '#perform' do
    subject(:perform) { CreatePayoutsJob.new.perform }

    let(:payouts_service) { instance_double(Payouts::Create) }

    before do
      allow(Payouts::Create).to receive(:new).with(Date.today - 1.day).and_return(payouts_service)
      allow(payouts_service).to receive(:call)
    end

    it 'starts payout creation process for the previous day' do
      perform

      expect(payouts_service).to have_received(:call)
    end

    context 'when there is a first day of the month' do
      let(:monthly_fees_service) { instance_double(MonthlyFees::Create) }

      before do
        travel_to Time.zone.local(2023, 06, 01)
        allow(Payouts::Create).to receive(:new).with(Date.parse('2023-05-31')).and_return(payouts_service)
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
        allow(Payouts::Create).to receive(:new).with(Date.parse('2023-06-04')).and_return(payouts_service)
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
