class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  validates :merchant_id, :amount, :paid_for, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
