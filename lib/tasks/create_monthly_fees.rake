desc 'Creates monthly fees for imported merchants and orders'
task create_monthly_fees: :environment do
  first_order = Order.order(:created_by_merchant_at).limit(1).first
  last_order = Order.order(created_by_merchant_at: :desc).limit(1).first
  return if first_order.nil?

  date_range = (first_order.created_by_merchant_at..last_order.created_by_merchant_at)
                 .to_a.group_by(&:month).values.map(&:first)
  date_range.each { MonthlyFees::Create.new(_1).call }
end
