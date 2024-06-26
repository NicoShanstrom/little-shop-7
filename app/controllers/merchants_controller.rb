class MerchantsController < ApplicationController
  def dashboard 
    @merchant = Merchant.find(params[:id])
  end

  def create
    merchant = Merchant.new(merchant_params)

    merchant.save!

    redirect_to admin_merchants_path
  end

  private
  def merchant_params
    params.require(:merchant).permit(:name)
  end
end