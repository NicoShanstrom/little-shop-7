require "rails_helper"

RSpec.describe Item, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: "merchant", status: 0)

    @table = create(:item, name: "table", merchant: @merchant1, unit_price: 4000, status: 0)
    @pen = create(:item, name: "pen", merchant: @merchant1, unit_price: 100, status: 1)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1, unit_price: 5000, status: 0)
    @mug = create(:item, name: "mug", merchant: @merchant1, unit_price: 200, status: 1)
    @ember = create(:item, name: "ember", merchant: @merchant1, unit_price: 600, status: 1)
    @plant = create(:item, name: "plant", merchant: @merchant1, unit_price: 400, status: 1)

    @items = [@table, @pen, @mat, @mug, @ember, @plant]

    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @customer3 = create(:customer)
    @customer4 = create(:customer)
    @customer5 = create(:customer)
    @customer6 = create(:customer)
    @customer7 = create(:customer)
    
    @invoice1 = create(:invoice, customer: @customer1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00", status: 0)
    @invoice2 = create(:invoice, customer: @customer2, created_at: "Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00", status: 1)
    @invoice3 = create(:invoice, customer: @customer3, created_at: "Sun, 17 Mar 2024 00:00:00.800830000 UTC +00:00", status: 2)
    @invoice4 = create(:invoice, customer: @customer4, created_at: "Sat, 16 Mar 2024 00:00:00.800830000 UTC +00:00", status: 1)
    @invoice5 = create(:invoice, customer: @customer6, created_at: "Tue, 26 Jun 1997 00:00:00.800830000 UTC +00:00", status: 0)
    @invoice6 = create(:invoice, customer: @customer6, created_at: "Tue, 21 Jun 1997 00:00:00.800830000 UTC +00:00", status: 0)

    @invoices_customer1 = create(:invoice, customer: @customer1, status: 1)
    @invoices_customer2 = create(:invoice, customer: @customer2, status: 1)
    @invoices_customer3 = create(:invoice, customer: @customer3, status: 1)
    @invoices_customer4 = create(:invoice, customer: @customer4, status: 1)
    @invoices_customer5 = create(:invoice, customer: @customer5, status: 1)
    @invoices_customer6 = create(:invoice, customer: @customer6, status: 1)

    @invoice_items1 = create(:invoice_item, invoice: @invoices_customer1, item: @table, status: 0, quantity: 10, unit_price: 4000 )
    @invoice_items2 = create(:invoice_item, invoice: @invoices_customer2, item: @pen, status: 0, quantity: 9, unit_price: 100 )
    
    
    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoices_customer1, result: 1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00")
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoices_customer2, result: 1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00")
    @transactions_invoice3 = create_list(:transaction, 6, invoice: @invoices_customer1, result: 1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00")
    @transactions_invoice4 = create_list(:transaction, 7, invoice: @invoices_customer2, result: 1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00")
    @transactions_invoice5 = create_list(:transaction, 3, invoice: @invoices_customer1, result: 1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00")
    @transactions_invoice6 = create_list(:transaction, 9, invoice: @invoices_customer2, result: 1, created_at: "Tues, 16 Apr 2024 00:00:00.800830000 UTC +00:00")
  end
  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:transactions).through(:invoices) }
    it { should have_many(:customers).through(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ disabled: 0, enabled: 1 }) }
  end

  describe 'instance methods' do
    describe "#top_selling_date" do
      it "returns top selling date for any item" do
        merchant7 = create(:merchant)
        invoice8 = create(:invoice, created_at: '1999-01-1 14:54:09')
        invoice9 = create(:invoice, created_at: '2024-03-29 14:54:09')
        invoice13 = create(:invoice, created_at: '2024-03-27 14:54:09')
        item8 = create(:item, merchant: merchant7)
        create(:invoice_item, unit_price: 2500000, quantity: 9, merchant: merchant7, invoice: invoice8, item: item8)
        create(:invoice_item, unit_price: 1250000, quantity: 11, merchant: merchant7, invoice: invoice9, item: item8)
        create(:invoice_item, unit_price: 1250000, quantity: 396, merchant: merchant7, invoice: invoice13, item: item8)
        create(:transaction, result: 1, invoice: invoice8)
        create(:transaction, result: 1, invoice: invoice9)
        create(:transaction, result: 1, invoice: invoice13)

        merchant9 = create(:merchant)
        invoice10 = create(:invoice, created_at: '2024-03-17 14:54:09')
        invoice11 = create(:invoice, created_at: '2024-03-19 14:54:09')
        invoice12 = create(:invoice, created_at: '2024-03-18 12:12:09')
        item9 = create(:item, merchant: merchant9)
        create(:invoice_item, unit_price: 200000, quantity: 9, merchant: merchant9, invoice: invoice10, item: item9)
        create(:invoice_item, unit_price: 190000, quantity: 1, merchant: merchant9, invoice: invoice11, item: item9)
        create(:invoice_item, unit_price: 190000, quantity: 500, merchant: merchant9, invoice: invoice12, item: item9)
        create(:transaction, result: 1, invoice: invoice10)
        create(:transaction, result: 1, invoice: invoice11)
        create(:transaction, result: 1, invoice: invoice12)
        item8.top_selling_date
        item9.top_selling_date
        
        expect(item8.top_selling_date.strftime("%m/%d/%y")).to eq("03/27/24")
        expect(item9.top_selling_date.strftime("%m/%d/%y")).to eq("03/18/24")
      end
    end  

    describe "#disabled?" do
      it "returns boolean for status" do
        @merchant1 = Merchant.create!(name: "merchant", status: 0)

        @table = @merchant1.items.create!(name: "table", description: "something", unit_price: 2, status: 0)
        @pen = @merchant1.items.create!(name: "pen", description: "something else", unit_price: 1, status: 1)

        expect(@table.disabled?).to be true
        expect(@pen.disabled?).to be false
      end
    end
    describe "#enabled?" do
      it "returns boolean for status" do
        @merchant1 = Merchant.create!(name: "merchant", status: 0)

        @table = @merchant1.items.create!(name: "table", description: "something", unit_price: 2, status: 0)
        @pen = @merchant1.items.create!(name: "pen", description: "something else", unit_price: 1, status: 1)

        expect(@table.enabled?).to be false
        expect(@pen.enabled?).to be true
      end
    end
  end
end
