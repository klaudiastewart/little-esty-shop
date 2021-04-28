class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @discounts = @merchant.bulk_discounts
    @holidays = NationalHolidayService.get_data
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new
    @holiday = NationalHolidayService.get_data[(params[:holiday].to_i)]
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    discount = @merchant.bulk_discounts.new(bulk_discount_params)

    if discount.save
      redirect_to "/merchant/#{@merchant.id}/bulk_discounts"
    else
      flash[:error] = "Please fill in all fields. #{error_message(discount.errors)}."
      redirect_to "/merchant/#{@merchant.id}/bulk_discounts/new"
    end
  end

  def destroy
    @merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.find(params[:id]).delete
    redirect_to "/merchant/#{@merchant.id}/bulk_discounts"
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.update(bulk_discount_params)
    redirect_to "/merchant/#{merchant.id}/bulk_discounts/#{bulk_discount.id}"
  end

  private

  def bulk_discount_params
    params.require(:bulk_discount).permit(:percent_discount, :quantity_threshold, :merchant_id)
  end
end
