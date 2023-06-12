desc 'Calculates statistics of fees and payouts per year'
task get_statistics: :environment do
  stats = Statistics::Index.new('2022-01-01', '2023-12-31').call
  puts stats
end
