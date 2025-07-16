Rails.application.routes.draw do
  root to: "subscriptions#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "subscriptions/index"

  # for handling stripe webhooks events
  resources :stripe_webhooks, only: [ :create ]
  resources :subscriptions, only: :index
end
