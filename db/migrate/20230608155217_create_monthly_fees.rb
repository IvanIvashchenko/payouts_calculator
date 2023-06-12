class CreateMonthlyFees < ActiveRecord::Migration[6.1]
  def change
    create_table :monthly_fees do |t|
      t.references :merchant, null: false, foreign_key: true
      t.date :paid_for, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
