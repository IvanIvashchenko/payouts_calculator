class CreatePayoutsJob
  include Sidekiq::Job

  def perform
    Merchant.select(:id).find_each do |merchant|
      CreateMerchantPayoutsJob.perform_async(merchant.id)
    end
    MonthlyFees::Create.new.call if Date.today.day == 1
  end
end
