class Admin::MerchantController < ApplicationController

  def index
    @merchants = Merchant.all
    @top_merchants = Merchant.top_merchants_revenue
    @enabled_merchants = Merchant.enabled_merchants
    @disabled_merchants = Merchant.disabled_merchants
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def new
    @merchant = Merchant.new
  end

  def create
    @merchant = Merchant.create!(name: params[:name])
    redirect_to "/admin/merchant"
  end

  def update
    @merchant = Merchant.find(params[:id])
    if params.include?(:merchant_status)
      if params[:merchant_status] == "disabled"
        @merchant.update(status: 1)
        redirect_to "/admin/merchant"
      else
        @merchant.update!(status: 0)
        redirect_to "/admin/merchant"
      end
    elsif @merchant.update!(merchant_params)
        flash[:message] = "Information has been successfully updated. #{error_message(@merchant.errors)}"
      redirect_to "/admin/merchant/#{@merchant.id}"
    end
  end

  private
  def merchant_params
    params.require(:merchant).permit(:name, :status)
  end
end
