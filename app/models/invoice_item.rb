class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_one :merchant, through: :item
  has_many :transactions, through: :invoice
  has_many :bulk_discounts, through: :item

  validates_presence_of :quantity,
                        :unit_price,
                        :status,
                        :item_id,
                        :invoice_id

  enum status: [:pending, :packaged, :shipped]

  def self.total_revenue
    sum("quantity * unit_price")
  end

  def self.best_item_sale_day
    select('invoices.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue').
    joins(:transactions).
    where(transactions: {result: :success}).
    group('invoices.id').
    order("revenue", "invoices.created_at").
    last.
    created_at
  end

  def self.items_not_shipped
    joins(:item, :invoice).
    select('invoices.created_at', 'items.name', 'invoices.id').
    order('invoices.created_at').
    where.not(status: 2)
  end

  def id_for_discount
    bulk_discounts
    .order(:percent_discount)
    .where("quantity_threshold <= ?", self.quantity)
    .pluck(:id)
    .last
  end
end
