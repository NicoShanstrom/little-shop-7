Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/', to: 'home#index'

  resources :merchants, only: [:show, :create] do
    member { get "dashboard"}
    resources :items, only: [:index, :show, :edit, :update, :new, :create], :controller => 'merchant_items'
    resources :invoices, only: [:index, :show], :controller => 'merchant_invoices'
    resources :coupons, only: [:index, :show]
  end

  resources :admin, only: [:index]

  namespace :admin do
    resources :merchants, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoices, only: [:index, :show, :update]
  end

  resources :invoice_items, only: [:update]
end
