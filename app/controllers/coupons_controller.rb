class CouponsController < ApplicationController
  def index
    # require 'pry'; binding.pry
    @merchant = Merchant.find(params[:merchant_id])
    @merchant_coupons = @merchant.coupons.all
  end
end