# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@merchant = Merchant.create(name: "Eugene", status: 1)
@customer1 = Customer.create(first_name: "Klaw", last_name: "S")
@invoice_1 = @customer1.invoices.create(status: 0)
@invoice_2 = @customer1.invoices.create(status: 1)
@item_1 = @merchant.items.create(name: "shoe", description: "put on", unit_price: 10, status: 0)
@item_2 = @merchant.items.create(name: "keyboard", description: "type", unit_price: 20, status: 0)
@invoice_item_1 = InvoiceItem.create!(item: @item_1, invoice: @invoice_1, quantity: 1, unit_price: 20, status: 0)
@invoice_item_2 = InvoiceItem.create!(item: @item_2, invoice: @invoice_1, quantity: 3, unit_price: 5, status: 0)
@invoice_item_3 = InvoiceItem.create!(item: @item_2, invoice: @invoice_2, quantity: 5, unit_price: 20, status: 0)
@discount_1 = @merchant.bulk_discounts.create!(percent_discount: 0.2, quantity_threshold: 3)

#invoice.invoice_items.total_revenue = 35
