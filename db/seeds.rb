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

@merchant = FactoryBot.create(:merchant)
@merchant0 = FactoryBot.create(:merchant, status: 'enabled')
@merchant01 = FactoryBot.create(:merchant, status: 'enabled')
#merchant0
@coupon1_merch0 = @merchant0.coupons.create(name: "70 off", code: "70 off", discount_amount: 70, percent_off: true, status: 0)
@coupon2_merch0 = @merchant0.coupons.create(name: "20 off", code: "20 off", discount_amount: 20, percent_off: false, status: 0)
#merchant01
@coupon1_merch01 = @merchant01.coupons.create(name: "30 off", code: "30 off", discount_amount: 30, percent_off: true, status: 0)
@coupon2_merch01 = @merchant01.coupons.create(name: "10 off", code: "10 off", discount_amount: 10, percent_off: false, status: 0)
#merchant0
@table = FactoryBot.create(:item, name: "table", merchant: @merchant0, status: 'enabled', unit_price: 200)
@chair = FactoryBot.create(:item, name: "chair", merchant: @merchant0, status: 'enabled', unit_price: 100)
#merchant01
@bike = FactoryBot.create(:item, name: "bike", merchant: @merchant01, status: 'enabled', unit_price: 400)
@car = FactoryBot.create(:item, name: "car", merchant: @merchant01, status: 'enabled', unit_price: 5000)

@customer1 = FactoryBot.create(:customer)
@customer2 = FactoryBot.create(:customer)

@invoice1_cust1 = FactoryBot.create(:invoice, customer: @customer1, status: 1, coupon_id: @coupon1_merch0.id)
@invoice2_cust1 = FactoryBot.create(:invoice, customer: @customer1, status: 1, coupon_id: @coupon2_merch0.id)

@invoice1_cust2 = FactoryBot.create(:invoice, customer: @customer2, status: 1, coupon_id: @coupon1_merch01.id)
@invoice2_cust2 = FactoryBot.create(:invoice, customer: @customer2, status: 1, coupon_id: @coupon2_merch01.id)

@invoice1_cust1_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 200, invoice: @invoice1_cust1, item: @table, status: 1 )
@invoice1_cust1_item2 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 5000, invoice: @invoice1_cust1, item: @car, status: 1 )
@invoice2_cust1_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 100, invoice: @invoice2_cust1, item: @chair, status: 1 )
@invoice2_cust1_item2 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 400, invoice: @invoice2_cust1, item: @bike, status: 1 )

@invoice1_cust2_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 400, invoice: @invoice1_cust2, item: @bike, status: 0 )
@invoice1_cust2_item2 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 5000, invoice: @invoice1_cust2, item: @car, status: 0 )
@invoice1_cust2_item3 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 100, invoice: @invoice1_cust2, item: @chair, status: 0 )
@invoice2_cust2_item1 = FactoryBot.create(:invoice_item, quantity: 1, unit_price: 200, invoice: @invoice2_cust2, item: @table, status: 0 )

@transaction1_invoice1 = FactoryBot.create(:transaction, invoice: @invoice1_cust1, result: 1)
@transaction2_invoice1 = FactoryBot.create(:transaction, invoice: @invoice2_cust1, result: 1)
@transaction1_invoice2 = FactoryBot.create(:transaction, invoice: @invoice1_cust2, result: 1)
@transaction2_invoice2 = FactoryBot.create(:transaction, invoice: @invoice2_cust2, result: 1)