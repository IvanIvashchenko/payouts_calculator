class CreatePayouts < ActiveRecord::Migration[6.1]
  def change
    create_table :payouts do |t|
      t.string :reference, null: false
      t.references :merchant, null: false, foreign_key: true
      t.date :payout_date, null: false
      t.decimal :total_amount, precision: 8, scale: 2, null: false
      t.decimal :total_fee, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
