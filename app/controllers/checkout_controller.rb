class CheckoutController < ApplicationController
  def create
    product = Product.find(params[:id])
    user = User.second
    stripe_service_obj = StripeService.new(product, user, nil, nil)
    @session = stripe_service_obj.stripe_checkout
    # respond_to do |format|
    #   format.js
    # end
    flash[:success] = 'Payment successful!'

    redirect_to @session.url
    # render json: {message: 'akjsdjfjlkjds'}
  end

  def execute
  end
end