require 'rails_helper'

RSpec.describe "Merchant Show Spec" do
  before :each do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)

    @table = create(:item, name: "table", merchant: @merchant1)
    @pen = create(:item, name: "pen", merchant: @merchant2)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1, unit_price: 5000)
    @mug = create(:item, name: "mug", merchant: @merchant1)
    @ember = create(:item, name: "ember", merchant: @merchant2)
    @plant = create(:item, name: "plant", merchant: @merchant2)
    visit merchant_item_path(@merchant1, @mat)
  end
  
  describe 'User story 7b' do
    it 'displays item attributes' do
      # And I see all of the item's attributes including:
      expect(page).to have_content(@mat.name)
      expect(page).to have_content(@mat.description)
      expect(page).to have_content("$50.00")
      expect(page).to_not have_content(@pen.name)
    end
  end

  describe "User Story 8" do
    it "contains a link to update the item information" do
      # As a merchant,
      # When I visit the merchant show page of an item (/merchants/:merchant_id/items/:item_id)
      # I see a link to update the item information.
      expect(page).to have_link("Update #{@mat.name} info")
      # When I click the link
      click_link("Update #{@mat.name} info")
      # Then I am taken to a page to edit this item
      expect(current_path).to eq(edit_merchant_item_path(@merchant1, @mat))
      # And I see a form filled in with the existing item attribute information
      expect(page).to have_field('name', with: @mat.name)
      expect(page).to have_field('description', with: @mat.description)
      expect(page).to have_field('unit_price', with: @mat.unit_price)
      expect(page).to have_field('status', with: @mat.status)
      # When I update the information in the form and I click ‘submit’
      fill_in 'name', with: 'Manduka yoga mat'
      click_button 'Submit'
      # Then I am redirected back to the item show page where I see the updated information
      expect(current_path).to eq(merchant_item_path(@merchant1, @mat))
      expect(page).to have_content("Manduka yoga mat")
      # And I see a flash message stating that the information has been successfully updated.
      expect(page).to have_content("#{@mat.name} info updated successfully.")
    end
  end
end