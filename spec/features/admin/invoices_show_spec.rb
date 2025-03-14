require 'rails_helper'

RSpec.describe "Admin Invoices Show Page" do
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
    visit "/admin/invoices/#{@invoice_1.id}"
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

  it 'can see total revenue from all items on invoice' do
    expect(page).to have_content(@invoice_1.invoice_items.total_revenue)
  end

  it 'can update item status on invoice' do
    within("#invoice-#{@invoice_1.id}") do
      select('completed')
      click_on('Update Invoice Status')
    end

    expect(current_path).to eq("/admin/invoices/#{@invoice_1.id}")

    within("#invoice-#{@invoice_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('completed')
      expect(page.find("option[selected = selected]").text).not_to eq('in progress')
    end

    within("#invoice-#{@invoice_1.id}") do
      select('in progress')
      click_on('Update Invoice Status')
    end

    expect(current_path).to eq("/admin/invoices/#{@invoice_1.id}")

    within("#invoice-#{@invoice_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('in progress')
    end

    within("#invoice-#{@invoice_1.id}") do
      select('cancelled')
      click_on('Update Invoice Status')
    end

    expect(current_path).to eq("/admin/invoices/#{@invoice_1.id}")

    within("#invoice-#{@invoice_1.id}") do
      expect(page.find("option[selected = selected]").text).to eq('cancelled')
    end
  end

  it 'shows the total revenue which includes bulk discounts' do
    expect(page).to have_content("Total Revenue w/ Discounts Applied: $#{@merchant.invoices.first.discounted_revenue}0")
    expect(page).to have_content("$30.20")
  end
end
