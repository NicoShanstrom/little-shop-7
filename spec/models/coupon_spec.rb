require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: "The best merchant")
    @five_off = @merchant1.coupons.create!(name: "5 off", code: "I got five off it", discount_amount: 5, percent_off: false, status: 1)
   
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
    describe "#limit_active_coupon" do
      it 'validates limit_active_coupon' do
        coupon1 = @merchant1.coupons.create!(name: "5 off", code: "I got five on it", discount_amount: 5, percent_off: false, status: 0)
        coupon2 = @merchant1.coupons.create!(name: "1 off", code: "I got one on it", discount_amount: 1, percent_off: false, status: 0)
        coupon3 = @merchant1.coupons.create!(name: "2 off", code: "I got two on it", discount_amount: 2, percent_off: false, status: 0)
        coupon4 = @merchant1.coupons.create!(name: "3 off", code: "I got three on it", discount_amount: 3, percent_off: false, status: 0)
        coupon5 = @merchant1.coupons.create!(name: "4 off", code: "I got four on it", discount_amount: 4, percent_off: false, status: 0)

        coupon6 = @merchant1.coupons.new(name: "6 off", code: "I got 6 on it", discount_amount: 6, percent_off: false, status: 0)
        coupon6.save
        
        expect(coupon6.errors[:base]).to include("Merchant can't have more than 5 active coupons")
      end
    end
  end

end
