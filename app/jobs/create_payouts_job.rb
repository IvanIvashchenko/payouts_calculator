class CreatePayoutsJob < ApplicationJob
  queue_as :default

  def perform
    date = Date.today - 1.day
    puts "Started payout process for #{date}..."

    Payouts::Create.new(date).call
    MonthlyFees::Create.new.call if Date.today.day == 1
  end
end
