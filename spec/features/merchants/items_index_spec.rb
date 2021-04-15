require 'rails_helper'

RSpec.describe "Merchant item index page" do
  before(:each) do
    @merchant_1 = Merchant.create!(name: 'Ice Cream Parlour')
    @merchant_2 = Merchant.create!(name: 'Ice Cream Parlour')
    @item_1 = @merchant_1.items.create!(name: 'Ice Cream Scoop', description: 'scoops ice cream', unit_price: 13)
    @item_2 = @merchant_1.items.create!(name: 'Back scratch', description: 'skirtch back', unit_price: 5)
    @item_3 = @merchant_2.items.create!(name: 'Pooper Scooper', description: 'holds doge poo', unit_price: 13)
    visit "/merchant/#{@merchant_1.id}/items"
  end

  it 'can see a list of the names of all items' do
    expect(page).to have_content("My Items")
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)
    expect(page).to_not have_content(@item_3.name)
    expect(page).to have_link(@item_1.name)
    expect(page).to have_link(@item_2.name)
  end

  it 'shows a button next to each item to enable or disable that item' do
    within("#item-#{@item_1.id}") do
      expect(page).to have_button("Enable")
      expect(page).to have_button("Disable")
    end

    within("#item-#{@item_2.id}") do
      expect(page).to have_button("Enable")
      expect(page).to have_button("Disable")
    end
  end

  it 'can click on enable and it updates item status to enable' do
    within("#item-#{@item_1.id}") do
      click_button "Enable"
    end

    expect(current_path).to eq("/merchant/#{@merchant_1.id}/items")
    expect(@item_1.status).to eq("enabled")
  end

  it 'can click on disable and it updates item status to disabled' do
    @item_1.update(status: 1)

    within("#item-#{@item_1.id}") do
      click_button "Disable"
    end

    expect(current_path).to eq("/merchant/#{@merchant_1.id}/items")
    expect(@item_1.status).to eq("disabled")
  end
end
