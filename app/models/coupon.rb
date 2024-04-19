class Coupon < ApplicationRecord
  enum :status, ['active', 'inactive'], validate: true
  
  belongs_to :merchant
  has_many :invoices
  has_many :customers, through: :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :merchant_id, message: "already exists. Please assign a different code." } #https://github.com/thoughtbot/shoulda-matchers/blob/main/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb 
  validates :discount_amount, presence: true
  validates :status, presence: true

  before_validation :limit_active_coupons, on: :create
  
  def limit_active_coupons
    if merchant.present? && merchant.coupons.active.count >= 5
      errors.add(:base, "Merchant can't have more than 5 active coupons")
    end
  end
end
