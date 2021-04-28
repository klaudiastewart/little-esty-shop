require 'rails_helper'

RSpec.describe "Merchant Bulk Discounts New Page" do
  before(:each) do
    @merchant = create(:merchant)

    @item_1 = create(:item, merchant: @merchant)
    @item_2 = create(:item, merchant: @merchant)
    @item_3 = create(:item, merchant: @merchant)
    @item_4 = create(:item, merchant: @merchant)
    @item_5 = create(:item, merchant: @merchant)
    @item_6 = create(:item, merchant: @merchant)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)
    @customer_6 = create(:customer)
    @customer_7 = create(:customer)

    @invoice_1 = Invoice.create!(status: 0, customer_id: @customer_1.id)
    @invoice_2 = Invoice.create!(status: 0, customer_id: @customer_2.id)
    @invoice_3 = Invoice.create!(status: 0, customer_id: @customer_3.id)
    @invoice_4 = Invoice.create!(status: 0, customer_id: @customer_4.id)
    @invoice_5 = Invoice.create!(status: 0, customer_id: @customer_5.id)
    @invoice_6 = Invoice.create!(status: 0, customer_id: @customer_6.id)
    @invoice_7 = Invoice.create!(status: 0, customer_id: @customer_7.id)

    @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_2.id, quantity: 10, unit_price: 20, status: 0)
    @invoice_item_2 =InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_3.id, quantity: 10, unit_price: 20, status: 2)
    @invoice_item_3 =InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_4.id, quantity: 10, unit_price: 20, status: 1)
    @invoice_item_4 =InvoiceItem.create!(item_id: @item_4.id, invoice_id: @invoice_5.id, quantity: 10, unit_price: 20, status: 1)
    @invoice_item_5 =InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_6.id, quantity: 10, unit_price: 20, status: 2)
    @invoice_item_6 =InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_7.id, quantity: 10, unit_price: 20, status: 2)
    @invoice_item_7 =InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_1.id, quantity: 10, unit_price: 20, status: 2)

    @transaction_1 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_1.id)
    @transaction_2 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_2.id)
    @transaction_3 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_3.id)
    @transaction_4 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_4.id)
    @transaction_5 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_5.id)
    @transaction_6 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_6.id)

    @transaction_7 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_7.id)
    @transaction_8 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_1.id)
    @transaction_9 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "failed", invoice_id: @invoice_2.id)
    @transaction_10 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_3.id)
    @transaction_11 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_4.id)
    @transaction_12 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_5.id)
    @transaction_13 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "failed", invoice_id: @invoice_6.id)
    @transaction_14 = Transaction.create!(credit_card_number: "123456789", credit_card_expiration_date: 1021, result: "success", invoice_id: @invoice_7.id)

    @discount_1 = @merchant.bulk_discounts.create!(percent_discount: 0.2, quantity_threshold: 3)
    @discount_2 = @merchant.bulk_discounts.create!(percent_discount: 0.5, quantity_threshold: 5)

    @holiday_1 = NationalHolidayService.get_data.first
    @holiday_2 = NationalHolidayService.get_data.second
    @holiday_3 = NationalHolidayService.get_data.last

    visit "/merchant/#{@merchant.id}/bulk_discounts/new"
  end

  it 'has a form that I can fill in to make a new discount' do
    expect(page).to have_content("Percent discount (please enter a decimal)")
    expect(page).to have_content("Quantity threshold")

    fill_in "Percent discount", with: 0.5
    fill_in "Quantity threshold", with: 7
    click_button "Submit"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")

    expect(page).to have_content("Percentage discount: 50.0%")
    expect(page).to have_content("Quantity threshold: 7")
  end

  it 'has a form that is already filled out for a holiday discount' do
    visit "/merchant/#{@merchant.id}/bulk_discounts/new?holiday=0"

    expect(page).to have_content("Discount name: #{@holiday_1.name}")
    click_button("Submit")

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
    expect(page).to have_content("20.0%")
    expect(page).to have_content("3")
  end

  it "does not submit if the form isn't filled all the way out" do
    visit "/merchant/#{@merchant.id}/bulk_discounts/new?holiday=0"

    fill_in "Percent discount", with: ""

    click_button("Submit")

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/new")
    expect(page).to have_content("Please fill in all fields. Percent discount can't be blank.")
  end
end
