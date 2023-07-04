# Checks minimum fee and creates monthly fee if needed
class CreateMonthlyFeesJob
  include Sidekiq::Job
  sidekiq_options retry: 2

  def perform
    MonthlyFees::Create.new.call
  end
end
