class StripeService
  include Rails.application.routes.url_helpers

  def initialize(product, user, payload, sig_header)
    @product = product
    @user = user
    @payload = payload
    @sig_header = sig_header
  end

  def stripe_checkout
    stripe_customer
    Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          unit_amount: @product.price,
          currency: 'usd',
          product_data: {
            name: @product.name,
          },
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: root_url( host: 'localhost', port: 3000 ),
      cancel_url: root_url( host: 'localhost', port: 3000 ),
    })
  end

  def process_webhook_event
    event = construct_event
    handle_event(event)
  end

  private

  def stripe_customer
    customer = Stripe::Customer.list(email: @user.email).data.first
    return customer if customer.present?
    
    customer = Stripe::Customer.create(email: @user.email, name: @user.name)
    @user.customer_id = customer.id
    customer
  end

  def construct_event
    begin
      event = Stripe::Webhook.construct_event(
        @payload, @sig_header, Rails.application.credentials.webhook_secret
      )
    rescue Stripe::StripeError, JSON::ParserError => e
      # Handle Stripe error or JSON parsing error
      raise e
    end
  
    event
  end

  def handle_event(event)
    case event.type
    when 'payment_intent.requires_action'
      'Please follow the instructions provided on the screen to fulfill the required action. Once you have completed the necessary steps, your payment will be processed successfully.'
    when 'checkout.session.completed'
      session = event.data.object
      product = Product.find_by(price: session.amount_total)
      product.increment!(:sales_count)
      product.save
      'checkout completed'
    when 'checkout.session.expired'
      'Your payment session has expired. Please initiate a new payment to proceed'  
    when 'payment_intent.failed'
      # Payment failed, handle accordingly
      'payment failed'
    when 'charge.failed', 'payment_intent.payment_failed'
      'your payment has failed. Please check your payment details and try again'
    else
      'An unknown error occurred.'
    end
  end

end