# Main job which runs payouts calculation process by merchant asynchronously
class CreatePayoutsJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform
    Merchant.select(:id).find_each do |merchant|
      CreateMerchantPayoutsJob.perform_async(merchant.id)
    end
  end
end
