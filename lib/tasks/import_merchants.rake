require 'csv'

desc 'Creates merchants from the CSV file'
task import_merchants: :environment do
  merchants_csv = CSV.read('data/merchants.csv', headers: true)
  merchants_csv.each do |row|
    Merchant.create!(
      email: row['email'],
      reference: row['reference'],
      live_on: Date.parse(row['live_on']),
      payout_frequency: row['disbursement_frequency'].underscore,
      min_monthly_fee: row['minimum_monthly_fee']
    )
  end
end
