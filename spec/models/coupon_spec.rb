require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: "The best merchant")
    @coupon1 = @merchant1.coupons.create!(name: "5 off", code: "I got five on it", discount_amount: 5, percent_off: false, status: 0)
    # @coupon2 = @merchant1.coupons.create!(name: "5 off", code: "I got five on it", discount_amount: 5, percent_off: false, status: 0)
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
    it { should validate_uniqueness_of(:code).scoped_to(:merchant_id).with_message("Already exists. Please assign a different code.")}
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ 'active' => 0, 'inactive' => 1 }) }
  end
end
