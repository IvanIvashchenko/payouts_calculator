class Merchant < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payouts, dependent: :destroy
  has_many :monthly_fees, dependent: :destroy

  enum payout_frequency: {
    daily: 'daily',
    weekly: 'weekly'
  }

  validates :reference, :email, :live_on, :min_monthly_fee, :payout_frequency,
            presence: true
  validates :reference, :email, uniqueness: true
  validates :min_monthly_fee, numericality: { greater_than_or_equal_to: 0 }
end
