# Creates payout for the certain merchant and previous day
class CreateMerchantPayoutsJob
  include Sidekiq::Job
  sidekiq_options retry: 2

  def perform(merchant_id)
    date = Date.today - 1.day
    puts "Started payout process for #{date} for #{merchant_id}..."

    Payouts::Create.new(merchant_id, date).call
  end
end
