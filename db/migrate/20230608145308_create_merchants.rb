class CreateMerchants < ActiveRecord::Migration[6.1]
  def change
    create_table :merchants do |t|
      t.string :reference, null: false
      t.string :email, null: false
      t.date :live_on, null: false
      t.decimal :min_monthly_fee, precision: 8, scale: 2, null: false
      t.column :payout_frequency, :payout_frequency, null: false

      t.timestamps
    end

    add_index :merchants, :reference, unique: true
    add_index :merchants, :email, unique: true
  end
end
