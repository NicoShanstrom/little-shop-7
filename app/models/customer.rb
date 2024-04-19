class Customer < ApplicationRecord
  has_many :invoices, dependent: :destroy
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :coupons, through: :invoices

  validates :first_name, presence: true
  validates :last_name, presence: true


  def self.goated_five_customers
    joins(:transactions)
    .select("customers.*, COUNT(DISTINCT transactions.id) AS transaction_count")
    .where("result = 1")
    .group(:id)
    .order(transaction_count: :desc)
    .limit(5)
  end
end
