class OffersController < ApplicationController
  def new
    @offer = Offer.new
  end

  def create
    @offer = Offer.new(params[:offer])
    @offers = @offer.get if @offer.valid? # just checks if data is valid
    render :new
  end
end
