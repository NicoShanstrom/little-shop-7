require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: "The best merchant")
    @five_off = @merchant1.coupons.create!(name: "5 off", code: "I got five off it", discount_amount: 5, percent_off: false, status: 1)
    
    @table = create(:item, name: "table", merchant: @merchant1)
    @pen = create(:item, name: "pen", merchant: @merchant1)
    
    @customer1 = create(:customer)
    @customer2 = create(:customer)
    
    @invoice_customer1 = create(:invoice, customer: @customer1, status: 1, coupon_id: @five_off.id)
    @invoice_customer2 = create(:invoice, customer: @customer2, status: 1, coupon_id: @five_off.id)
    
    @invoice_items1 = create(:invoice_item, invoice: @invoice_customer1, item: @table, status: 0 )
    @invoice_items2 = create(:invoice_item, invoice: @invoice_customer2, item: @pen, status: 0 )

    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 1)
    # require 'pry'; binding.pry
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
    it { should have_many(:customers).through(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:discount_amount) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:code).scoped_to(:merchant_id).with_message("already exists. Please assign a different code.")}
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ 'active' => 0, 'inactive' => 1 }) }
  end

  describe 'instance methods' do
    describe "#active_coupon_limit" do
      it 'validates active_coupon_limit' do
        coupon1 = @merchant1.coupons.create!(name: "5 off", code: "I got five on it", discount_amount: 5, percent_off: false)
        coupon2 = @merchant1.coupons.create!(name: "1 off", code: "I got one on it", discount_amount: 1, percent_off: false)
        coupon3 = @merchant1.coupons.create!(name: "2 off", code: "I got two on it", discount_amount: 2, percent_off: false)
        coupon4 = @merchant1.coupons.create!(name: "3 off", code: "I got three on it", discount_amount: 3, percent_off: false)
        coupon5 = @merchant1.coupons.create!(name: "4 off", code: "I got four on it", discount_amount: 4, percent_off: false)

        coupon6 = @merchant1.coupons.new(name: "6 off", code: "I got 6 on it", discount_amount: 6, percent_off: false)
        coupon6.save
        
        expect(coupon6.errors[:base]).to include("Merchant can't have more than 5 active coupons")
        # require 'pry'; binding.pry
      end
    end

    describe "#coupon_count" do
      it "displays the count of a coupon used on invoices with successful transactions" do
        expect(@five_off.coupon_count).to eq(2)
      end
    end

    describe '#percent_or_integer_off' do
      it 'adjusts the coupon discount amount to a decimal if percent off is true' do
        merchant0 = create(:merchant, status: 'enabled')
        coupon1 = merchant0.coupons.create!(name: "10 off", code: "10 off", discount_amount: 10, percent_off: true, status: 0)
        coupon2 = merchant0.coupons.create!(name: "1 off", code: "1 off", discount_amount: 1, percent_off: false, status: 0)
        # require 'pry'; binding.pry
        expect(coupon1.percent_or_integer_off).to eq(0.1)
        expect(coupon2.percent_or_integer_off).to eq(1)
      end
    end
  end

end
