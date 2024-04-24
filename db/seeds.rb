# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Transaction.destroy_all
InvoiceItem.destroy_all
Invoice.destroy_all
Item.destroy_all
Coupon.destroy_all
Customer.destroy_all
Merchant.destroy_all

@merchant1 = FactoryBot.create(:merchant)
@merchant0 = FactoryBot.create(:merchant, status: 'enabled')
@merchant01 = FactoryBot.create(:merchant, status: 'enabled')

@coupon1 = @merchant0.coupons.create(name: "70 off", code: "70 off", discount_amount: 70, percent_off: true, status: 0)
@coupon2 = @merchant01.coupons.create(name: "10 off", code: "10 off", discount_amount: 20, percent_off: false, status: 0)

@table = FactoryBot.create(:item, name: "table", merchant: @merchant0, status: 'enabled', unit_price: 100)
@car = FactoryBot.create(:item, name: "car", merchant: @merchant01, status: 'enabled', unit_price: 1000)

@customer1 = FactoryBot.create(:customer)

@invoice1 = FactoryBot.create(:invoice, customer: @customer1, status: 1, coupon_id: @coupon1.id)
@invoice2 = FactoryBot.create(:invoice, customer: @customer1, status: 1, coupon_id: @coupon2.id)

@invoice1_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 100, invoice: @invoice1, item: @table, status: 0 )
@invoice1_item2 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 1000, invoice: @invoice1, item: @car, status: 0 )

@invoice2_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 100, invoice: @invoice2, item: @table, status: 0 )
@invoice2_item2 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 1000, invoice: @invoice2, item: @car, status: 0 )

@transactions_invoice1 = FactoryBot.create(:transaction, invoice: @invoice1, result: 1)
@transactions_invoice1 = FactoryBot.create(:transaction, invoice: @invoice2, result: 1)