require "rails_helper"

RSpec.describe "the admin invoices show page" do
  before(:each) do
    @customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
    @customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')
    @customer3 = create(:customer, first_name: 'Spongebob', last_name: 'SquarePants')
    @customer4 = create(:customer, first_name: 'Luffy', last_name: 'Monkey')

    @item1 = create(:item, name: "Cool Item Name")
    @item2 = create(:item)
    @item3 = create(:item)
    @item4 = create(:item)
    @item5 = create(:item)
    @item6 = create(:item)
    @item7 = create(:item)
    @item8 = create(:item)
    @item9 = create(:item)
    @item10 = create(:item)
    @item11 = create(:item)

    @invoice1 = create(:invoice, customer: @customer1, created_at: 'Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00', status: 0)
    @invoice2 = create(:invoice, customer: @customer2, created_at: 'Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice3 = create(:invoice, customer: @customer3, created_at: 'Sun, 17 Mar 2024 00:00:00.800830000 UTC +00:00', status: 2)
    @invoice4 = create(:invoice, customer: @customer4, created_at: 'Sat, 16 Mar 2024 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice5 = create(:invoice, customer: @customer1, created_at: 'Tue, 25 Jun 1997 00:00:00.800830000 UTC +00:00', status: 0)

    create(:invoice_item, item: @item1, invoice: @invoice1, quantity: 10, unit_price: 5000, status: 2)
    create(:invoice_item, item: @item2, invoice: @invoice1, quantity: 3, unit_price: 55000, status: 1)
    create(:invoice_item, item: @item8, invoice: @invoice1, quantity: 8, unit_price: 41000, status: 0)
    create(:invoice_item, item: @item5, invoice: @invoice1, quantity: 4, unit_price: 1000, status: 2)
    create(:invoice_item, item: @item3, invoice: @invoice2, quantity: 5, unit_price: 2000, status: 2)
    create(:invoice_item, item: @item4, invoice: @invoice2, quantity: 5, unit_price: 5050, status: 1)
    create(:invoice_item, item: @item3, invoice: @invoice3, quantity: 1, unit_price: 400000, status: 0)
    create(:invoice_item, item: @item11, invoice: @invoice4, quantity: 1, unit_price: 1000, status: 2)
    create(:invoice_item, item: @item10, invoice: @invoice4, quantity: 5, unit_price: 5000, status: 2)
    create(:invoice_item, item: @item9, invoice: @invoice4, quantity: 3, unit_price: 2000, status: 1)
    create(:invoice_item, item: @item1, invoice: @invoice5, quantity: 6, unit_price: 5100, status: 0)
    create(:invoice_item, item: @item2, invoice: @invoice5, quantity: 8, unit_price: 4500, status: 1)
  end

  describe 'User Story 33' do
    it 'lists all invoice IDs in the system and each ID links to the admin invoice show page' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_content("Invoice ##{@invoice1.id}")
      expect(page).to have_content("Status: in progress")
      expect(page).to have_content("Created on: Monday, April 15, 1996")
      expect(page).to have_content("Customer: Ron Burgundy")

      expect(page).to_not have_content("Invoice ##{@invoice2.id}")
      expect(page).to_not have_content("Customer: Fred Flintstone")
    end
  end

  describe 'User Story 34' do
    it 'lists all of the items for that invoice including their name, quantity ordered, price sold for and status' do
      visit admin_invoice_path(@invoice1)

      within '#admin_invoice_items' do
        expect(page).to have_content("Cool Item Name")
        expect(page).to have_content("10")
        expect(page).to have_content("$50.00")
        expect(page).to have_content("Shipped")

        @invoice1.invoice_items.each do |invoice_item|
          within "#invoice_item_#{invoice_item.id}_info" do
            expect(page).to have_content("#{invoice_item.item.name}")
            expect(page).to have_content(" #{invoice_item.quantity}")
            expect(page).to have_content("#{invoice_item.status.capitalize}")
          end
        end
      end
    end
  end

  describe 'User Story 35' do
    it 'shows the total revenue that will be generated from this invoice' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_content('Total Revenue: $5,470.00')

      visit admin_invoice_path(@invoice2)

      expect(page).to have_content('Total Revenue: $352.50')
    end
  end

  describe 'User Story 36' do
    it 'has a select field and the current status is selected and i can select a different status and click Update Invoice Status to update its status and Im redirected back to the show page' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_field(:status, with: 'in progress')

      select('completed', from: :status)
      click_button('Update Invoice Status')

      expect(current_path).to eq(admin_invoice_path(@invoice1))
      expect(page).to have_field(:status, with: 'completed')
    end
  end

  describe 'US8/coupons' do
    it 'displays the coupon name and code (if one was used), subtotal(before coupon) and grand total(after coupon) for an invoice' do
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
      # When I visit one of my admin invoice show pages
      visit admin_invoice_path(invoice1)
      # I see the name and code of the coupon that was used (if there was a coupon applied)
      expect(page).to have_content("Coupon used on invoice name: #{coupon1.name}")
      expect(page).to have_content("Coupon used on invoice code: #{coupon1.code}")
      # And I see both the subtotal revenue from that invoice (before coupon) and the grand total revenue (after coupon) for this invoice.
      expect(page).to have_content("Total Revenue: $11.00")
      expect(page).to have_content("Grand Total: $10.30")
    end

    it 'applies discount to total amount of invoice if the coupon is a dollar off and not percent off' do
      merchant0 = create(:merchant, status: 'enabled')
      merchant01 = create(:merchant, status: 'enabled')

      coupon1 = merchant0.coupons.create!(name: "10 off", code: "10 off", discount_amount: 10, percent_off: true, status: 0)
      coupon2 = merchant01.coupons.create!(name: "20 off", code: "20 off", discount_amount: 20, percent_off: false, status: 0)

      table = create(:item, name: "table", merchant: merchant0, status: 'enabled', unit_price: 100)
      car = create(:item, name: "car", merchant: merchant01, status: 'enabled', unit_price: 1000)
      bike = create(:item, name: "bike", merchant: merchant01, status: 'enabled', unit_price: 333)
      
      customer1 = create(:customer)
      customer2 = create(:customer)
      
      invoice1 = create(:invoice, customer: customer1, status: 1, coupon_id: coupon1.id)
      invoice2 = create(:invoice, customer: customer2, status: 1, coupon_id: coupon2.id)
      invoice3 = create(:invoice, customer: customer2, status: 1)
      # 1. There may be invoices with items from more than 1 merchant. Coupons for a merchant only apply to items from that merchant.
      invoice1_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice1, item: table, status: 0 )
      invoice1_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice1, item: car, status: 0 )

      invoice2_item1 = create(:invoice_item, quantity: 1, unit_price: 100, invoice: invoice2, item: table, status: 0 )
      invoice2_item2 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice2, item: car, status: 0 )
      invoice3_item1 = create(:invoice_item, quantity: 1, unit_price: 1000, invoice: invoice3, item: car, status: 0 )
      invoice3_item2 = create(:invoice_item, quantity: 1, unit_price: 333, invoice: invoice3, item: bike, status: 0 )
      
      transactions_invoice1 = create(:transaction, invoice: invoice1, result: 1)
      transactions_invoice1 = create(:transaction, invoice: invoice2, result: 1)
      # 2. When a coupon with a dollar-off value is used with an invoice with multiple merchants' items, the dollar-off amount applies to the total amount even though there may be items present from another merchant.
      visit admin_invoice_path(invoice2)
      # I see the name and code of the coupon that was used (if there was a coupon applied)
      expect(page).to have_content("Coupon used on invoice name: #{coupon2.name}")
      expect(page).to have_content("Coupon used on invoice code: #{coupon2.code}")
      # And I see both the subtotal revenue from that invoice (before coupon) and the grand total revenue (after coupon) for this invoice.
      expect(page).to have_content("Total Revenue: $11.00")
      expect(page).to have_content("Grand Total: $10.80")

      visit admin_invoice_path(invoice3)
      expect(page).to have_content("Total Revenue: $13.33")
      expect(page).to have_content("Grand Total: $13.33")
      expect(page).to_not have_content("Coupon used on invoice name:")
    end
  end
end