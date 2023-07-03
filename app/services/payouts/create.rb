module Payouts
  # Creates payouts for specified merchant with suitable orders
  # Example:
  # Payouts::Create.new(merchant_id, date).call - will check and create daily payouts for the <date> and weekly payouts
  #   for the week before <date>
  class Create < ApplicationService
    attr_reader :date, :date_week_ago, :merchant_id

    def initialize(merchant_id, date)
      @merchant_id = merchant_id
      @date = date
      @date_week_ago = @date - 6.days
    end

    def call
      return if orders.empty?

      total_fee = calculate_fee(orders)
      ActiveRecord::Base.transaction do
        payout = Payout.create!(
          total_amount: orders.sum(&:amount),
          total_fee:,
          merchant_id:,
          payout_date: date
        )
        Order.where(id: orders.pluck(:id)).update_all(payout_id: payout.id)
      end
    end

    private

    def orders
      @orders ||= Order.select(:id, :amount)
                    .joins(:merchant)
                    .where(payout_id: nil, merchant_id:)
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
