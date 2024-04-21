class Invoice < ApplicationRecord
  enum :status, ['in progress', 'completed', 'cancelled'], validate: true

  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  belongs_to :coupon, optional: true

  def self.incomplete_invoices
    joins(:invoice_items)
    .distinct
    .where.not(invoice_items: { status: 2 })
    .order(:created_at)
  end

  def formatted_date
    self.created_at.strftime("%A, %B %d, %Y")
  end

  def customer_name
    "#{customer.first_name} #{customer.last_name}"
  end

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_revenue_for_merchant(merchant)
    items.where(merchant: merchant)
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def grand_total
    total_revenue - percent_or_integer_off
  end

  def percent_or_integer_off
    if coupon.nil?
      0
    elsif coupon.percent_off?
      coupon.discount_amount/100
    else
      coupon.discount_amount
    end
  end
end
