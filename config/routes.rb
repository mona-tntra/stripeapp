Rails.application.routes.draw do
  resources :products
  root 'products#index'
  post "checkout/create", to: "checkout#create"
  get "checkout/execute", to: "checkout#execute"
  post 'webhooks/stripe', to: 'webhooks#stripe'
  post 'webhooks/paypal', to: 'webhooks#paypal'

  post 'paypal_payment/create', to: 'paypal_payment#create'
  get 'paypal_payment/execute', to: 'paypal_payment#execute'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
