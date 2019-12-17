Rails.application.routes.draw do
  devise_for :users
  resources :histories
  root 'histories#index'
  get 'payments/index', to: 'payments#index', as: 'index'
  post 'payments/create_qr_payment', to: 'payments#create_qr_payment', as: 'create_qr_payment'
  post 'payments/callback', to: 'payments#callback', as: 'callback'
end
