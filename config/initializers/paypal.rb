require 'paypal-sdk-rest'
PayPal::SDK.configure(
  mode: Rails.application.credentials.paypal[:mode],
  client_id: Rails.application.credentials.paypal[:paypal_client_id],
  client_secret: Rails.application.credentials.paypal[:paypal_client_secret],
  ssl_options: { ca_file: nil }
)