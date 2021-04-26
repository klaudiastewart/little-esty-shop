require 'rails_helper'

RSpec.describe "Merchant Invoices Show" do
  before(:each) do
    @merchant = Merchant.create!(name: 'Ice Cream Parlour')
    @item_1 = @merchant.items.create!(name: 'Ice Cream Scoop', description: 'scoops ice cream', unit_price: 13)
    @item_2 = @merchant.items.create!(name: 'Ice Cream Cones', description: 'holds the ice cream', unit_price: 10)
    @item_3 = @merchant.items.create!(name: 'Sprinkles', description: 'makes ice cream pretty', unit_price: 3)
    @customer = Customer.create!(first_name: 'Stuart', last_name: 'Little')
    @invoice_1 = Invoice.create!(status: 0, customer_id: "#{@customer.id}")
    @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 13, status: 0)
    @invoice_item_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 10, status: 0)
    @invoice_item_3 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_1.id, quantity: 3, unit_price: 3, status: 0)
    @discount_1 = @merchant.bulk_discounts.create!(percent_discount: 0.2, quantity_threshold: 3)
    visit "/merchant/#{@merchant.id}/invoices/#{@invoice_1.id}"
  end

  it 'can see invoice id, status, created_at date, customer first and last name' do
    expect(page).to have_content(@invoice_1.id)
    expect(page).to have_content(@invoice_1.status)
    expect(page).to have_content(@invoice_1.created_at.strftime("%A, %B %d, %Y"))
    expect(page).to have_content(@customer.first_name)
    expect(page).to have_content(@customer.last_name)
  end

  it 'can see all items and their names, quantity ordered, price items sold for, and invoice item status' do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@invoice_item_1.quantity)
    expect(page).to have_content(@invoice_item_1.unit_price)
    expect(page).to have_content(@invoice_item_1.status)
  end

  it 'can update item status on invoice' do
    within("#invoice_item-#{@invoice_item_1.id}") do
      select('packaged')
      click_on('Update Item Status')
    end

    expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice_1.id}")

    within("#invoice_item-#{@invoice_item_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('packaged')
    end

    within("#invoice_item-#{@invoice_item_1.id}") do
      select('shipped')
      click_on('Update Item Status')
    end

    expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice_1.id}")

    within("#invoice_item-#{@invoice_item_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('shipped')
    end

    within("#invoice_item-#{@invoice_item_1.id}") do
      select('pending')
      click_on('Update Item Status')
    end

    expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice_1.id}")

    within("#invoice_item-#{@invoice_item_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('pending')
    end
  end

  it 'shows total revenue for my merchant that includes bulk discounts' do
    #@merchant.invoices.last.invoice_items.total_revenue => $32
    #@merchant.invoices.last.discounted_revenue => $30.2, 20% off $9 is $1.80
    expect(page).to have_content("Total Revenue w/ discounts applied: $#{@merchant.invoices.first.discounted_revenue}0")
    expect(page).to have_content("$30.20")
  end

  it 'shows a link for the show page for the bulk discount if any were applied' do
    within("#invoice_item-#{@invoice_item_1.id}") do
      expect(page).to_not have_link("#{@discount_1.id}")
      expect(page).to have_content("There are no discounts for invoice item, #{@invoice_item_1.item.name}.")
    end

    within("#invoice_item-#{@invoice_item_2.id}") do
      expect(page).to_not have_link("#{@discount_1.id}")
      expect(page).to have_content("There are no discounts for invoice item, #{@invoice_item_2.item.name}.")
    end

    within("#invoice_item-#{@invoice_item_3.id}") do
      expect(page).to have_link("#{@discount_1.id}")
      click_link "#{@discount_1.id}"
    end

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@discount_1.id}")
  end
end
