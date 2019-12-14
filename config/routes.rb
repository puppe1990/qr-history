Rails.application.routes.draw do
  resources :histories
  root 'histories#index'
end
