class PaypalService
  include Rails.application.routes.url_helpers
  def initialize(product, payment_id, payer_id, event)
    @product = product
    @event = event
    @payment_id = payment_id
    @payer_id = payer_id
  end

  def handle_paypal_event
    case @event.event_type
    when 'PAYMENTS.PAYMENT.CREATED'
      'payment approved'
    end
  end

  def create_paypal_payment
    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: { payment_method: "paypal" },
      redirect_urls: {
        return_url: "#{root_url( host: 'localhost', port: 3000 )}/paypal_payment/execute",
        cancel_url: root_url( host: 'localhost', port: 3000 )
      },
      transactions: [{
        amount: { total: @product.price, currency: "USD" },
        description: "Payment transaction description."
      }]
    })

    if payment.create
      payment.links.find { |link| link.method == "REDIRECT" }.href
    else
      flash[:error] = payment.error
      "/"
    end
  end

  def execute_paypal_payment
    payment = PayPal::SDK::REST::Payment.find(@payment_id)
    if payment.execute(payer_id: @payer_id)
      # Payment successful
      return { success: true, message: 'Payment completed successfully.' }
    else
      # Display an error message
      return { success: false, message: payment.error }
    end
  end
end