require 'rails_helper'

RSpec.describe 'merchant dashboard show page', type: :feature do
  before(:each) do
    @merchant1 = create(:merchant)
    # @merchant2 = create(:merchant)
    @coupon1 = @merchant1.coupons.create!(name: "5 off", code: "I got five on it", discount_amount: 5, percent_off: false, status: 0)
    @coupon2 = @merchant1.coupons.create!(name: "10 off", code: "Its a ten", discount_amount: 10, status: 0)
    @coupon3 = @merchant1.coupons.create!(name: "7 off", code: "Lucky 7", discount_amount: 7, percent_off: false, status: 0)
    @coupon4 = @merchant1.coupons.create!(name: "15 off", code: "Buy more", discount_amount: 15, status: 0)
    @coupon5 = @merchant1.coupons.create!(name: "11 off", code: "Make a wish", discount_amount: 11, percent_off: false, status: 0)
    @coupon6 = @merchant1.coupons.create!(name: "40 off", code: "40 off of freedom", discount_amount: 40, status: 1)

    @table = create(:item, name: "table", merchant: @merchant1)
    @pen = create(:item, name: "pen", merchant: @merchant1)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1)
    @mug = create(:item, name: "mug", merchant: @merchant1)
    @ember = create(:item, name: "ember", merchant: @merchant1)
    @plant = create(:item, name: "plant", merchant: @merchant1)
    # @items_merchant2 = create_list(:item, 5, merchant: @merchant2)

    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @customer3 = create(:customer)
    @customer4 = create(:customer)
    @customer5 = create(:customer)
    @customer6 = create(:customer)

    @invoice_customer1 = create(:invoice, customer: @customer1, status: 1, coupon_id: @coupon1.id)
    @invoice_customer2 = create(:invoice, customer: @customer2, status: 1, coupon_id: @coupon2.id)
    @invoice_customer3 = create(:invoice, customer: @customer3, status: 1, coupon_id: @coupon3.id)
    @invoice_customer4 = create(:invoice, customer: @customer4, status: 1, coupon_id: @coupon4.id)
    @invoice_customer5 = create(:invoice, customer: @customer5, status: 1, coupon_id: @coupon5.id)
    @invoice_customer6 = create(:invoice, customer: @customer6, status: 1)

    @invoice_items1 = create(:invoice_item, invoice: @invoice_customer1, item: @table, status: 0 ) #pending
    @invoice_items2 = create(:invoice_item, invoice: @invoice_customer2, item: @pen, status: 0 ) #pending
    @invoice_items3 = create(:invoice_item, invoice: @invoice_customer3, item: @mat, status: 1 ) #packaged
    @invoice_items4 = create(:invoice_item, invoice: @invoice_customer4, item: @mug, status: 1 ) #packaged
    @invoice_items5 = create(:invoice_item, invoice: @invoice_customer5, item: @ember, status: 2 )#shiped
    @invoice_items6 = create(:invoice_item, invoice: @invoice_customer6, item: @plant, status: 2 )#shipped
    
    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 1)
    @transactions_invoice3 = create_list(:transaction, 6, invoice: @invoice_customer3, result: 1)
    @transactions_invoice4 = create_list(:transaction, 7, invoice: @invoice_customer4, result: 1)
    @transactions_invoice5 = create_list(:transaction, 3, invoice: @invoice_customer5, result: 1)
    @transactions_invoice6 = create_list(:transaction, 9, invoice: @invoice_customer6, result: 1)
    # require 'pry'; binding.pry
    visit merchant_coupons_path(@merchant1)
  end

  describe 'US2/coupons' do
    it 'displays a link to create a new coupon for a merchant' do
      # When I visit my coupon index page
      # I see a link to create a new coupon.
      expect(page).to have_link("Create new coupon", href: new_merchant_coupon_path(@merchant1))
      # When I click that link 
      click_link("Create new coupon")
      # I am taken to a new page where I see a form to add a new coupon.
      expect(current_path).to eq(new_merchant_coupon_path(@merchant1))
      # When I fill in that form with a name, unique code, an amount, and whether that amount is a percent or a dollar amount
      fill_in 'Name', with: 'Price is right'
      fill_in 'Code', with: '1 dolla Bob'
      fill_in 'Discount amount', with: 1
      fill_in 'Percent off?', with: false
      fill_in 'Status', with: 'inactive'
      # And click the Submit button
      click_button 'submit'
      # I'm taken back to the coupon index page
      expect(current_path).to eq(merchant_coupons_path(@merchant1))
      # And I can see my new coupon listed.
      within '.coupons' do
        expect(page).to have_content('Coupon name: Price is right')
      end
    end

    it 'can only create coupons with a unique coupon code for that merchant' do
      # 2. Coupon code entered is NOT unique
      click_link("Create new coupon")
      expect(current_path).to eq(new_merchant_coupon_path(@merchant1))
      bobcoupon = @merchant1.coupons.create!(name: 'Bobby B', code: '1 dolla Bob', discount_amount: 1, percent_off: false, status: 'inactive')
      fill_in 'Name', with: 'Bob Barker'
      fill_in 'Code', with: '1 dolla Bob'
      fill_in 'Discount amount', with: 1
      fill_in 'Percent off?', with: false
      fill_in 'Status', with: 'inactive'
      # And click the Submit button
      click_button 'submit'
      # expect(current_path).to eq(new_merchant_coupon_path(@merchant1))
      # require 'pry'; binding.pry
      expect(page).to have_content("Code already exists. Please assign a different code.")
      expect(page).to have_content("Create a new coupon for #{@merchant1.name}!")
    end
    
    it 'only allows a merchant to have a max of 5 active coupons at one time' do
      # 1. This Merchant already has 5 active coupons
      click_link("Create new coupon")
      expect(current_path).to eq(new_merchant_coupon_path(@merchant1))
      fill_in 'Name', with: 'IYKYK'
      fill_in 'Code', with: 'Surprise'
      fill_in 'Discount amount', with: 9
      fill_in 'Percent off?', with: false
      fill_in 'Status', with: "active"
      # And click the Submit button
      click_button 'submit'
      # expect(current_path).to eq(new_merchant_coupon_path(@merchant1))
      expect(page).to have_content("Merchant can't have more than 5 active coupons")
      expect(page).to have_content("Create a new coupon for #{@merchant1.name}!")
    end
  end

  describe "US6/coupons" do
    it 'Groups coupons by active and inactive' do
      # As a merchant
      # When I visit my coupon index page
      # I can see that my coupons are separated between active and inactive coupons. 
    end
  end
end