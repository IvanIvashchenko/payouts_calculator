class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :merchant, null: false, foreign_key: true
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.date :created_by_merchant_at, null: false
      t.references :payout, null: true, foreign_key: true

      t.timestamps
    end
  end
end
