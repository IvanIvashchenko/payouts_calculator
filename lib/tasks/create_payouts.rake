desc 'Creates payouts for imported merchants and orders'
task create_payouts: :environment do
  first_order = Order.order(:created_by_merchant_at).limit(1).first
  last_order = Order.order(created_by_merchant_at: :desc).limit(1).first
  return if first_order.nil?

  date_range = first_order.created_by_merchant_at..last_order.created_by_merchant_at + 1.week
  date_range.each { Payouts::Create.new(_1).call }
end
