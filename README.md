# README

### How to set up and run

#### Dependencies and versions

*nix based OS (as the cron tool is used)
Ruby 3.1.2
Rails 6.1
Postgresql 14

#### Set up DB and libraries

Database configuration uses environment variables. To set your custom values for development/test DBs, please
copy `.env.template` file to `env.development` and `.env.test` files with the corresponding values.

To install all required gems and create databases, run

```shell
bundle install

rails db:create
rails db:migrate
```

To import merchants and orders from the CSV files, execute
```shell
rake import_merchants
rake import_orders
```

To create payouts and monthly fees which are related
with imported on previous step merchants and orders, run

```shell
rake create_payouts
rake create_monthly_fees
```

To get the statistics by the years, run
```shell
rake get_statistics
```

To run the process of payouts creation automatically, we need to update the crontab file.
This could be done with the next command:
```shell
whenever --update-crontab --set environment='development'
```

Also, there are very small amount of specs added to the project.
They could be started with:
```shell
bundle exec rspec spec
```
