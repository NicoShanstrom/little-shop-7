class Coupon < ApplicationRecord
  enum :status, ['active', 'inactive'], validate: true
  
  belongs_to :merchant
  has_many :invoices
  has_many :customers, through: :invoices

  validates :name, presence: true
  validates :code, presence: true
  validates :discount_amount, presence: true
  validates :percent_off, presence: true
  validates :status, presence: true
end
