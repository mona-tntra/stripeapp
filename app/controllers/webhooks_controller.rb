class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:paypal]
  protect_from_forgery with: :null_session
  require 'paypal-sdk-rest'

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    stripe_service_obj = StripeService.new(nil, nil, payload, sig_header)
    message = stripe_service_obj.process_webhook_event
    render json: {message: message}
  end

 def paypal
    request.body.rewind
    payload = request.body.read

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      return render :nothing => true, :status => 400
    end
    service_obj = PaypalService.new(nil, nil, nil, event)
    message = service_obj.handle_paypal_event
    render json: {message: message}
  end 
end 