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

  def total_revenue_invoice_items_merchant_coupon
    if coupon.present?
      InvoiceItem.joins(item: :merchant)
      .where("merchants.id = ? AND invoice_id = ?", coupon.merchant_id, self.id)
      .sum("invoice_items.unit_price * invoice_items.quantity")
    else
      total_revenue
    end
  end
  
  def grand_total
    total_revenue - coupon_discount_amount
  end

  def coupon_discount_amount
    if coupon.present?
      if coupon.percent_off?
        total_revenue_invoice_items_merchant_coupon * coupon.percent_or_integer_off
      else
        coupon.percent_or_integer_off
      end
    else
      0
    end
  end
end
