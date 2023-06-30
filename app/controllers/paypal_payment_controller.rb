class PaypalPaymentController < ApplicationController
  def create
    product = Product.find(params[:id])
    service_obj = PaypalService.new(product, nil, nil, nil)
    redirect_url = service_obj.create_paypal_payment
    redirect_to redirect_url
  end

  def execute
    service_obj = PaypalService.new(nil, params[:paymentId], params[:PayerID], nil)
    payment_result = service_obj.execute_paypal_payment
    if payment_result[:success]
      flash[:success] = payment_result[:message]
      redirect_to root_url
    else
      flash[:error] = payment_result[:message]
      redirect_to root_url
    end
  end
end