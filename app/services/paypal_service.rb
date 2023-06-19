class PaypalService
  def initialize(product, user, base_url, payment_id, payer_id, event)
    @product = product
    @base_url = base_url
    @event = event
    @payment_id = payment_id
    @payer_id = payer_id
    @user = user
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
        return_url: "#{@base_url}/paypal_payment/execute",
        cancel_url: "#{@base_url}/"
      },
      transactions: [{
        amount: { total: @product.price, currency: "USD" },
        description: "Payment transaction description."
      }]
    })

    if payment.create
      @order = Order.create(status: 0, payment_method: 'paypal', product_id: @product.id, user_id: @user.id )
      payment.links.find { |link| link.method == "REDIRECT" }.href
    else
      flash[:error] = payment.error
      "/"
    end
  end

  def execute_paypal_payment
    payment = PayPal::SDK::REST::Payment.find(@payment_id)
    if payment.execute(payer_id: @payer_id)
      @order.update(status: 1)
      # Payment successful
      return { success: true, message: 'Payment completed successfully.' }
    else
      # Display an error message
      return { success: false, message: payment.error }
    end
  end
end