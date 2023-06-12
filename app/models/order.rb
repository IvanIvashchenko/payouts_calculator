class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :payout, optional: true

  validates :merchant_id, :amount, :created_by_merchant_at,
            presence: true
  validates :amount, numericality: { greater_than: 0 }
end
