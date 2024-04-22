require "rails_helper"

RSpec.describe InvoiceItem, type: :model do
  before :each do
    @customer1 = create(:customer, first_name: "Ron", last_name: "Burgundy")
    @customer2 = create(:customer, first_name: "Fred", last_name: "Flintstone")
    @customer3 = create(:customer, first_name: "Spongebob", last_name: "SquarePants")
    @customer4 = create(:customer, first_name: "Luffy", last_name: "Monkey")
    @customer5 = create(:customer, first_name: "Jack", last_name: "Sparrow")
    @customer6 = create(:customer, first_name: "Hank", last_name: "Hill")

    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    @merchant3 = create(:merchant)
    @merchant4 = create(:merchant)

    @table = create(:item, name: "table", merchant: @merchant1, unit_price: 4000,status: 0)#disabled
    @pen = create(:item, name: "pen", merchant: @merchant1, unit_price: 100, status: 0)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1, unit_price: 5000, status: 0)
    @mug = create(:item, name: "mug", merchant: @merchant1, unit_price: 200, status: 1)#enabled
    @ember = create(:item, name: "ember", merchant: @merchant2, unit_price: 600, status: 1)
    @plant = create(:item, name: "plant", merchant: @merchant2, unit_price: 400, status: 1)

    @invoice1 = create(:invoice, customer: @customer1, created_at: "Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00", status: 0)
    @invoice2 = create(:invoice, customer: @customer2, created_at: "Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00", status: 1)
    @invoice3 = create(:invoice, customer: @customer3, created_at: "Sun, 17 Mar 2024 00:00:00.800830000 UTC +00:00", status: 2)
    @invoice4 = create(:invoice, customer: @customer4, created_at: "Sat, 16 Mar 2024 00:00:00.800830000 UTC +00:00", status: 1)
    @invoice5 = create(:invoice, customer: @customer5, created_at: "Tue, 26 Jun 1997 00:00:00.800830000 UTC +00:00", status: 0)
    @invoice6 = create(:invoice, customer: @customer6, created_at: "Tue, 21 Jun 1997 00:00:00.800830000 UTC +00:00", status: 0)
    
    invoice_item1 = create(:invoice_item, item: @table, invoice: @invoice1, quantity: 10, unit_price: 4100, status: 2)
    invoice_item2 = create(:invoice_item, item: @pen, invoice: @invoice2, quantity: 4, unit_price: 200, status: 2)
    invoice_item3 = create(:invoice_item, item: @mat, invoice: @invoice3, quantity: 5, unit_price: 5100, status: 2)
    invoice_item4 = create(:invoice_item, item: @mug, invoice: @invoice4, quantity: 4, unit_price: 5100, status: 1)
    invoice_item5 = create(:invoice_item, item: @ember, invoice: @invoice5, quantity: 1, unit_price: 5100, status: 0)
    invoice_item6 = create(:invoice_item, item: @plant, invoice: @invoice6, quantity: 1, unit_price: 1000, status: 2)

    @transaction1 = create(:transaction, result: 1, invoice_id: @invoice1.id)
    @transaction2 = create(:transaction, result: 1, invoice_id: @invoice2.id)
    @transaction3 = create(:transaction, result: 1, invoice_id: @invoice3.id)
    @transaction4 = create(:transaction, result: 1, invoice_id: @invoice4.id)
    @transaction5 = create(:transaction, result: 1, invoice_id: @invoice5.id)
    @transaction6 = create(:transaction, result: 1, invoice_id: @invoice6.id)
  end
  describe "relationships" do
    it { should belong_to(:item) }
    it { should have_one(:merchant).through(:item) }
    it { should belong_to(:invoice) }
    # .transaction is a built in AR method and cant use as an association
    # it { should have_one(:transaction).through(:invoice) }
    it { should have_one(:customer).through(:invoice) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ pending: 0, packaged: 1, shipped: 2 }) }
  end

  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
  end
end
