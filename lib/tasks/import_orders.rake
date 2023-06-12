require 'csv'

desc 'Creates orders from the CSV file'
task import_orders: :environment do
  orders_csv = CSV.read('data/orders.csv', headers: true, col_sep: ';')
  merchants = Merchant.select(:reference, :id)
  return if merchants.empty?

  orders = orders_csv.map do |row|
    merchant = merchants.find { _1.reference == row['merchant_reference'] }
    next unless merchant

    {
      merchant_id: merchant.id,
      amount: row['amount'],
      created_by_merchant_at: Date.parse(row['created_at']),
      created_at: Time.now(),
      updated_at: Time.now()
    }
  end
  Order.insert_all(orders.compact)
end
