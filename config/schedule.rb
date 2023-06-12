set :output, 'log/cron.log'

every 1.day, at: '8:00 am' do
  runner 'CreatePayoutsJob.perform_now'
end
