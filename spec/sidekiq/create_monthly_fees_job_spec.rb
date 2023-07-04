require 'rails_helper'

RSpec.describe CreateMonthlyFeesJob, type: :job do
  describe '#perform' do
    subject(:perform) { CreateMonthlyFeesJob.new.perform }

    let(:monthly_fees_service) { instance_double(MonthlyFees::Create) }

    before do
      allow(MonthlyFees::Create).to receive(:new).and_return(monthly_fees_service)
      allow(monthly_fees_service).to receive(:call)
    end

    it 'starts monthly fees creation process for the previous month' do
      perform

      expect(monthly_fees_service).to have_received(:call).once.with(no_args)
    end
  end
end
