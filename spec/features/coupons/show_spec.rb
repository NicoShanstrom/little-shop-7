require 'rails_helper'

RSpec.describe 'merchant coupon show page', type: :feature do
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
    @invoice_customer2 = create(:invoice, customer: @customer2, status: 1, coupon_id: @coupon1.id)
    @invoice_customer3 = create(:invoice, customer: @customer3, status: 1, coupon_id: @coupon3.id)
    @invoice_customer4 = create(:invoice, customer: @customer4, status: 1, coupon_id: @coupon4.id)
    @invoice_customer5 = create(:invoice, customer: @customer5, status: 0, coupon_id: @coupon5.id)
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
    visit merchant_coupon_path(@merchant1, @coupon1)
  end

  describe 'US3/coupons' do
    it 'displays the coupons name, code, percent/dollar off value, status, and count of how many times the coupon has been used' do
      # As a merchant 
      # When I visit a merchant's coupon show page
      # I see that coupon's name and code 
      expect(page).to have_content("#{@merchant1.name}'s #{@coupon1.name} coupon!")
      # And I see the percent/dollar off value
      expect(page).to have_content("Discount amount: #{@coupon1.discount_amount}")
      expect(page).to have_content("Percent off?: #{@coupon1.percent_off}")
      # As well as its status (active or inactive)
      expect(page).to have_content("Coupon status: #{@coupon1.status}")
      # And I see a count of how many times that coupon has been used.
      expect(page).to have_content("How many times has #{@coupon1.name} been used? 2")
      # (Note: "use" of a coupon should be limited to successful transactions.)
    end
  end

  describe "US4/coupons" do
    it 'displays a button to deactive a coupon' do
      # As a merchant 
      # When I visit one of my active coupon's show pages
      # I see a button to deactivate that coupon
      # require 'pry'; binding.pry
      expect(page).to have_button("deactivate #{@coupon1.name}")
      # When I click that button
      click_button "deactivate #{@coupon1.name}"
      # I'm taken back to the coupon show page 
      expect(current_path).to eq(merchant_coupon_path(@merchant1, @coupon1))
      # And I can see that its status is now listed as 'inactive'.
      expect(page).to have_content("Coupon status: inactive")
    end
    it 'cannot deactivate a coupon that is associated with any in progress invoices' do
      # * Sad Paths to consider: 
      # 1. A coupon cannot be deactivated if there are any pending invoices with that coupon.
      visit merchant_coupon_path(@merchant1, @coupon5)
      expect(page).to have_button("deactivate #{@coupon5.name}")
      click_button "deactivate #{@coupon5.name}"
      expect(current_path).to eq(merchant_coupon_path(@merchant1, @coupon5))
      expect(page).to have_content("Can't deactivate coupon with pending invoices")
      expect(page).to have_content("Coupon status: active")
    end
  end

  describe "US5/coupons" do
    it 'displays a button to activate a coupon' do
      # As a merchant 
      # When I visit one of my inactive coupon's show pages
      # I see a button to activate that coupon
      # require 'pry'; binding.pry
      merchant = Merchant.create!(name: "Good")
      coupon7 = merchant.coupons.create!(name: "9 off", code: "9 off", discount_amount: 9, status: 1)
      visit merchant_coupon_path(merchant, coupon7)
      expect(page).to have_button("activate #{coupon7.name}")
      # When I click that button
      click_button "activate #{coupon7.name}"
      # I'm taken back to the coupon show page 
      expect(current_path).to eq(merchant_coupon_path(merchant, coupon7))
      # And I can see that its status is now listed as 'inactive'.
      expect(page).to have_content("Coupon status: active")
    end
  end
end