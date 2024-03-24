Rails.application.routes.draw do
  get 'export', to: 'export#index'
  resources :imports
  resources :stats, only: :index do
    collection do
      post :update
    end
  end

  root to: 'home#index'
  devise_for :users

  get 'points', to: 'points#index'

  namespace :api do
    namespace :v1 do
      resources :points
    end
  end
end
