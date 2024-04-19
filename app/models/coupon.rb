class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  has_many :customers, through: :invoices
end
