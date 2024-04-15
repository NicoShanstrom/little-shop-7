class Merchant < ApplicationRecord
  enum :status, [:disabled, :enabled], validate: true

  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  validates :name, presence: true

  def top_five_customers
    customers.joins(:transactions).where("result = 1").select("customers.*, COUNT(DISTINCT transactions.id) AS transaction_count").order("transaction_count DESC").group(:id).limit(5)
  end


  def packaged_items 
    items.joins(:invoice_items).where("invoice_items.status = 1").select("items.*, invoice_items.invoice_id, invoice_items.created_at")
  end

  def self.top_5_merchants_by_revenue
    joins(:transactions)
    .where("transactions.result = 1")
    .group(:id)
    .select("merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue")
    .order(total_revenue: :desc)
    .limit(5)
  end

  def top_sales_day
    invoices.joins(:invoice_items)
    .select("DATE_TRUNC('day', invoices.created_at) AS date, SUM(invoice_items.quantity * invoice_items.unit_price) AS daily_revenue")
    .group("date").order("daily_revenue DESC, date DESC").limit(1).first.date
  end
end
