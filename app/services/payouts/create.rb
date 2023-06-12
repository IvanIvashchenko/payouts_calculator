module Payouts
  # Creates payouts for all merchants with suitable orders
  # Example:
  # Payouts::Create.new(date).call - will check and create daily payouts for the <date> and weekly payouts
  #   for the week before <date>
  class Create < ApplicationService
    attr_reader :date, :date_week_ago

    def initialize(date)
      @date = date
      @date_week_ago = @date - 6.days
    end

    def call
      merchant_ids = orders.pluck(:merchant_id).uniq
      merchant_ids.each do |merchant_id|
        merchant_orders = orders.select { _1.merchant_id == merchant_id }
        total_fee = calculate_fee(merchant_orders)
        ActiveRecord::Base.transaction do
          payout = Payout.create!(
            total_amount: merchant_orders.sum(&:amount),
            total_fee:,
            merchant_id:,
            payout_date: date
          )
          Order.where(id: merchant_orders.pluck(:id)).update_all(payout_id: payout.id)
        end
      end
    end

    private

    def orders
      @orders ||= Order.joins(:merchant)
                    .where('payout_id IS NULL')
                    .where(<<~SQL.squish, date:, date_week_ago:)
                         (payout_frequency = 'daily' AND created_by_merchant_at = :date) OR
                         (payout_frequency = 'weekly' AND
                           EXTRACT(DOW FROM live_on) = EXTRACT(DOW FROM TIMESTAMP :date) AND
                           created_by_merchant_at BETWEEN :date_week_ago AND :date)
      SQL
    end

    def calculate_fee(merchant_orders)
      merchant_orders.reduce(0) do |fee, order|
        if order.amount < 50
          fee + (order.amount / 100).round(2)
        elsif order.amount < 300
          fee + (order.amount / 100 * 0.95).round(2)
        else
          fee + (order.amount / 100.0 * 0.85).round(2)
        end
      end
    end
  end
end
