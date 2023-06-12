class Payout < ApplicationRecord
  before_create :generate_reference, unless: :reference?

  belongs_to :merchant
  has_many :orders

  validates :merchant_id, :payout_date, :total_amount, :total_fee, presence: true
  validates :reference, uniqueness: true
  validates :total_amount, :total_fee, numericality: { greater_than: 0 }

  private

  def generate_reference
    self.reference = "#{self.merchant.reference}_#{self.payout_date}"
  end
end
