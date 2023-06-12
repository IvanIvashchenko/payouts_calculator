module Statistics
  # Calculates stats of payouts and fees
  # Example:
  # Statistics::Index.new('2021-01-01', '2022-11-11').call
  # =>
  # [{
  #   year: 2021,
  #   payouts_number: nil,
  #   payouts_sum=: nil,
  #   payouts_fees_sum: nil,
  #   monthly_fees_number:nil,
  #   monthly_fees_sum: nil
  # }, {
  #   year=>2022,
  #   payouts_number: 21,
  #   payouts_sum: 0.29751025e6,
  #   payouts_fees_sum: 0.276759e4,
  #   monthly_fees_number: 29,
  #   monthly_fees_sum: 0.645e3
  # }]
  class Index < ApplicationService
    attr_reader :start_date, :end_date

    def initialize(start_date, end_date)
      @start_date = Date.parse(start_date)
      @end_date = Date.parse(end_date)
    end

    def call
      (start_date.year..end_date.year).map do |year|
        payout_stats_by_year = payouts_stats.find { _1.year == year }
        fee_stats_by_year = fees_stats.find { _1.year == year }
        {
          year:,
          payouts_number: payout_stats_by_year&.payouts_number,
          payouts_sum: payout_stats_by_year&.payouts_sum,
          payouts_fees_sum: payout_stats_by_year&.fee,
          monthly_fees_number: fee_stats_by_year&.fees_number,
          monthly_fees_sum: fee_stats_by_year&.fees_sum,
        }
      end
    end

    private

    def payouts_stats
      @payouts_stats ||= Payout.where(payout_date: start_date..end_date)
                               .select(<<~SQL.squish).group(:year)
                                  DATE_PART('YEAR', payout_date) as year,
                                  COUNT(*) AS payouts_number,
                                  SUM(total_amount) AS payouts_sum,
                                  SUM(total_fee) AS fee
      SQL
    end

    def fees_stats
      @fees_stats ||= MonthlyFee.where(paid_for: start_date..end_date)
                                .select("DATE_PART('YEAR', paid_for) as year, count(*) AS fees_number, sum(amount) AS fees_sum")
                                .group(:year)
    end
  end
end
