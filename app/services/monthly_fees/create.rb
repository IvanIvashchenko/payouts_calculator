module MonthlyFees
  # Creates monthly fees for all merchants which generates less fee than minimum monthly value
  # Example:
  # MonthlyFees::Create.new.call - to check and create monthly fees for previous month from today
  # MonthlyFees::Create.new(date).call - to check and create monthly fees for previous month from custom date
  class Create < ApplicationService
    attr_reader :fee_month

    def initialize(fee_month = Date.today.prev_month)
      @fee_month = fee_month
    end

    def call
      payouts = Payout.where(payout_date: fee_month.beginning_of_month..fee_month.end_of_month)
      merchants = Merchant.where('live_on < ?', fee_month.next_month.beginning_of_month)
      merchants.each { create_fee!(_1, payouts) }
    end

    private

    def create_fee!(merchant, payouts)
      monthly_fee = payouts.filter { _1.merchant_id == merchant.id }.sum(&:total_fee)
      return if monthly_fee >= merchant.min_monthly_fee

      MonthlyFee.create!(
        merchant_id: merchant.id,
        paid_for: fee_month,
        amount: merchant.min_monthly_fee - monthly_fee
      )
    end
  end
end
