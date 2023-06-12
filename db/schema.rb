# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_06_08_155217) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "merchants" because of following StandardError
#   Unknown type 'payout_frequency' for column 'payout_frequency'

  create_table "monthly_fees", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.date "paid_for", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_monthly_fees_on_merchant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.date "created_by_merchant_at", null: false
    t.bigint "payout_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["payout_id"], name: "index_orders_on_payout_id"
  end

  create_table "payouts", force: :cascade do |t|
    t.string "reference", null: false
    t.bigint "merchant_id", null: false
    t.date "payout_date", null: false
    t.decimal "total_amount", precision: 8, scale: 2, null: false
    t.decimal "total_fee", precision: 8, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_payouts_on_merchant_id"
  end

  add_foreign_key "monthly_fees", "merchants"
  add_foreign_key "orders", "merchants"
  add_foreign_key "orders", "payouts"
  add_foreign_key "payouts", "merchants"
end
