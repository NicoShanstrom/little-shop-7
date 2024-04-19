require 'rails_helper'

RSpec.describe Coupon, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: "The best merchant")
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
    it { should validate_presence_of(:percent_off) }
    it { should validate_presence_of(:status) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ 'active' => 0, 'inactive' => 1 }) }
  end
end
