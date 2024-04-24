require "rails_helper"

RSpec.describe Invoice, type: :model do
  before :each do
    @invoice = create(:invoice)
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
   
    @items_merchant1 = create_list(:item, 5, merchant: @merchant1)
    @items_merchant2 = create_list(:item, 5, merchant: @merchant2)
   
    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @customer3 = create(:customer)
    @customer4 = create(:customer)
    @customer5 = create(:customer)
    @customer6 = create(:customer)
    @customer7 = create(:customer)

    @invoice_customer1 = create(:invoice, customer: @customer1, status: 1)
    @invoice_customer2 = create(:invoice, customer: @customer2, status: 1)
    @invoice_customer3 = create(:invoice, customer: @customer3, status: 1)
    @invoice_customer4 = create(:invoice, customer: @customer4, status: 1)
    @invoice_customer5 = create(:invoice, customer: @customer5, status: 1)
    @invoice_customer6 = create(:invoice, customer: @customer6, status: 2)
    @invoice_customer7 = create(:invoice, customer: @customer7, status: 2)

    @invoice_items1 = create(:invoice_item, invoice: @invoice_customer1, item: @items_merchant1.first, status: 2 )
    @invoice_items2 = create(:invoice_item, invoice: @invoice_customer2, item: @items_merchant1.first, status: 2 )
    @invoice_items3 = create(:invoice_item, invoice: @invoice_customer3, item: @items_merchant1.second, status: 2 )
    @invoice_items4 = create(:invoice_item, invoice: @invoice_customer4, item: @items_merchant1.third, status: 2 )
    @invoice_items5 = create(:invoice_item, invoice: @invoice_customer5, item: @items_merchant1.third, status: 2 )
    @invoice_items6 = create(:invoice_item, invoice: @invoice_customer6, item: @items_merchant1.fifth, status: 2 )
    @invoice_items7 = create(:invoice_item, invoice: @invoice_customer7, item: @items_merchant1.fifth, status: 1 )
    @invoice_items8 = create(:invoice_item, invoice: @invoice_customer1, item: @items_merchant2.first, status: 2 )
    @invoice_items9 = create(:invoice_item, invoice: @invoice_customer2, item: @items_merchant2.first, status: 2 )
    @invoice_items10 = create(:invoice_item, invoice: @invoice_customer3, item: @items_merchant2.second, status: 2 )
    @invoice_items11 = create(:invoice_item, invoice: @invoice_customer4, item: @items_merchant2.third, status: 2 )
    @invoice_items12 = create(:invoice_item, invoice: @invoice_customer5, item: @items_merchant2.third, status: 0 )
    @invoice_items13 = create(:invoice_item, invoice: @invoice_customer6, item: @items_merchant2.fifth, status: 0 )
    @invoice_items14 = create(:invoice_item, invoice: @invoice_customer7, item: @items_merchant2.fifth, status: 1 )

    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 0)
    @transactions_invoice3 = create_list(:transaction, 6, invoice: @invoice_customer3, result: 1)
    @transactions_invoice4 = create_list(:transaction, 7, invoice: @invoice_customer4, result: 1)
    @transactions_invoice5 = create_list(:transaction, 3, invoice: @invoice_customer5, result: 0)
    @transactions_invoice6 = create_list(:transaction, 9, invoice: @invoice_customer6, result: 1)
    @transactions_invoice7 = create_list(:transaction, 10, invoice: @invoice_customer7, result: 0)
    @transactions_invoice8 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice9 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 1)
    @transactions_invoice10 = create_list(:transaction, 6, invoice: @invoice_customer3, result: 1)
    @transactions_invoice11 = create_list(:transaction, 7, invoice: @invoice_customer4, result: 0)
    @transactions_invoice12 = create_list(:transaction, 3, invoice: @invoice_customer5, result: 0)
    @transactions_invoice13 = create_list(:transaction, 9, invoice: @invoice_customer6, result: 0)
    @transactions_invoice14 = create_list(:transaction, 10, invoice: @invoice_customer7, result: 0)
  end

  describe "relationships" do
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should belong_to(:coupon).optional }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ 'in progress' => 0, 'completed' => 1, 'cancelled' => 2 }) }
  end

  describe "class methods" do
    it ".query for incomplete invoices ordered by oldest to newest" do
      list_test = Invoice.all.incomplete_invoices.limit(3)
      expect(list_test).to match_array([@invoice_customer7, @invoice_customer6, @invoice_customer5])
    end
  end

  describe "instance method" do

    describe '#coupon_discount_amount' do
      it 'adjusts the discount_amount to a decimal if a coupon has a percent_off value of true, returns 0 if no coupon' do
        merchant0 = create(:merchant, status: 'enabled')
        merchant01 = create(:merchant, status: 'enabled')
        
        coupon1 = merchant0.coupons.create!(name: "10 off", code: "10 off", discount_amount: 10, percent_off: true, status: 0)
        
        table = create(:item, name: "table", merchant: merchant0, status: 'enabled', unit_price: 10)
        junk = create(:item, name: "junk", merchant: merchant01, status: 'enabled', unit_price: 1000000)
        
        customer1 = create(:customer)
        customer2 = create(:customer)
        
        invoice_1 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon1.id)
        invoice_2 = create(:invoice, customer: customer2, status: 1)
        
        invoice1_item1 = create(:invoice_item, quantity: 1, unit_price: 10, invoice: invoice_1, item: table, status: 0 )
        invoice2_item1 = create(:invoice_item, quantity: 1, unit_price: 1000000, invoice: invoice_2, item: junk, status: 0 )
        
        transactions_invoice1 = create(:transaction, invoice: invoice_1, result: 1)
        transactions_invoice2 = create(:transaction, invoice: invoice_2, result: 1)
        # require 'pry'; binding.pry
        expect(invoice_1.coupon_discount_amount).to eq(1.0)
        expect(invoice_2.coupon_discount_amount).to eq(0)
      end
    end

    describe '#grand_total' do
      it 'calculates the grand total of an invoice using the coupons discount amount' do
        merchant0 = create(:merchant, status: 'enabled')
        coupon1 = merchant0.coupons.create!(name: "10 off", code: "10 off", discount_amount: 10, percent_off: true, status: 0)
        table = create(:item, name: "table", merchant: merchant0, status: 'enabled', unit_price: 10)
        customer1 = create(:customer)
        invoice_1 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon1.id)
        invoice_item1 = create(:invoice_item, quantity: 1, unit_price: 10, invoice: invoice_1, item: table, status: 0 )
        transactions_invoice1 = create(:transaction, invoice: invoice_1, result: 1)
        # require 'pry'; binding.pry
        expect(invoice_1.grand_total).to eq(9.0)
      end
    end

    describe "#total_revenue_invoice_items_merchant_coupon" do
      it "IF a coupon is present, returns ONLY the revenue of a SPECIFIC invoice's items associated with the merchant that OWNS the coupon" do
        merchant0 = create(:merchant, status: 'enabled')
        merchant01 = create(:merchant, status: 'enabled')

        coupon1 = merchant0.coupons.create!(name: "70 off", code: "70 off", discount_amount: 70, percent_off: true, status: 0)
        coupon2 = merchant01.coupons.create!(name: "10 off", code: "10 off", discount_amount: 20, percent_off: false, status: 0)

        table = create(:item, name: "table", merchant: merchant0, status: 'enabled', unit_price: 100)
        car = create(:item, name: "car", merchant: merchant01, status: 'enabled', unit_price: 1000)
        
        customer1 = create(:customer)
        
        invoice1 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon1.id)
        invoice2 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon2.id)
        # 1. There may be invoices with items from more than 1 merchant. Coupons for a merchant only apply to items from that merchant.
        invoice1_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice1, item: table, status: 0 )
        invoice1_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice1, item: car, status: 0 )

        invoice2_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice2, item: table, status: 0 )
        invoice2_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice2, item: car, status: 0 )
        
        transactions_invoice1 = create(:transaction, invoice: invoice1, result: 1)
        transactions_invoice1 = create(:transaction, invoice: invoice2, result: 1)

        expect(invoice1.total_revenue_invoice_items_merchant_coupon).to eq(100)
        expect(invoice2.total_revenue_invoice_items_merchant_coupon).to eq(1000)
        
        expect(invoice1.total_revenue_invoice_items_merchant_coupon).to_not eq(200)
        expect(invoice2.total_revenue_invoice_items_merchant_coupon).to_not eq(2000)
      end

      it 'IF a coupon is NOT present, returns the total revenue of the invoice' do
        merchant0 = create(:merchant, status: 'enabled')
        merchant01 = create(:merchant, status: 'enabled')

        coupon1 = merchant0.coupons.create!(name: "70 off", code: "70 off", discount_amount: 70, percent_off: true, status: 0)
        coupon2 = merchant01.coupons.create!(name: "10 off", code: "10 off", discount_amount: 20, percent_off: false, status: 0)

        table = create(:item, name: "table", merchant: merchant0, status: 'enabled', unit_price: 100)
        car = create(:item, name: "car", merchant: merchant01, status: 'enabled', unit_price: 1000)
        
        customer1 = create(:customer)
        
        invoice1 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon1.id)
        invoice2 = create(:invoice, customer: customer1, status: 1)
        # 1. There may be invoices with items from more than 1 merchant. Coupons for a merchant only apply to items from that merchant.
        invoice1_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice1, item: table, status: 0 )
        invoice1_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice1, item: car, status: 0 )

        invoice2_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice2, item: table, status: 0 )
        invoice2_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice2, item: car, status: 0 )
        
        transactions_invoice1 = create(:transaction, invoice: invoice1, result: 1)
        transactions_invoice1 = create(:transaction, invoice: invoice2, result: 1)

        expect(invoice2.total_revenue_invoice_items_merchant_coupon).to eq(1100)
      end
    end

    describe 'formatted date' do
      it "#formatted_date" do
        @customer = Customer.create!(first_name: "Blake", last_name: "Sergesketter")
        @invoice = Invoice.create!(status: 1, customer_id: @customer.id, created_at: "Sat, 13 Apr 2024 23:10:10.717784000 UTC +00:00")
        expect(@invoice.formatted_date).to eq("Saturday, April 13, 2024")
        #Saturday, April 13, 2024
      end
    end

    it 'customer_name' do
      customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
      invoice1 = create(:invoice, customer: customer1)
      customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')
      invoice2 = create(:invoice, customer: customer2)
  
      expect(invoice1.customer_name).to eq('Ron Burgundy')
      expect(invoice2.customer_name).to eq('Fred Flintstone')
    end

    it 'total_revenue' do
      customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
      customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')

      item1 = create(:item, name: "Cool Item Name")
      item2 = create(:item)

      invoice1 = create(:invoice, customer: customer1, created_at: 'Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00', status: 0)
      invoice2 = create(:invoice, customer: customer2, created_at: 'Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00', status: 1)

      create(:invoice_item, item: item1, invoice: invoice1, quantity: 10, unit_price: 5000, status: 2) 
      create(:invoice_item, item: item2, invoice: invoice1, quantity: 3, unit_price: 55000, status: 1) 
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 8, unit_price: 41000, status: 0) 
      create(:invoice_item, item: item2, invoice: invoice1, quantity: 4, unit_price: 1000, status: 2) 

      create(:invoice_item, item: item1, invoice: invoice2, quantity: 5, unit_price: 2000, status: 2)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 5, unit_price: 5050, status: 1)

      expect(invoice1.total_revenue).to eq(547000)
      expect(invoice2.total_revenue).to eq(35250)
    end

    it 'total_revenue_for_merchant' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)

      item1 = create(:item, merchant: merchant1)
      item2 = create(:item, merchant: merchant1)
      item3 = create(:item, merchant: merchant2)
      item4 = create(:item, merchant: merchant2)

      invoice1 = create(:invoice)
      invoice2 = create(:invoice)

      create(:invoice_item, invoice: invoice1, item: item1, quantity: 10, unit_price: 400)
      create(:invoice_item, invoice: invoice1, item: item2, quantity: 5, unit_price: 12000)
      create(:invoice_item, invoice: invoice1, item: item3, quantity: 8, unit_price: 5000)
      create(:invoice_item, invoice: invoice1, item: item4, quantity: 1, unit_price: 4000)
      create(:invoice_item, invoice: invoice2, item: item1, quantity: 11, unit_price: 650)
      create(:invoice_item, invoice: invoice2, item: item3, quantity: 7, unit_price: 8000)
      create(:invoice_item, invoice: invoice2, item: item4, quantity: 5, unit_price: 90000)

      expect(invoice1.total_revenue_for_merchant(merchant1)).to eq(64000)
      expect(invoice2.total_revenue_for_merchant(merchant1)).to eq(7150)
    end
  end
end
