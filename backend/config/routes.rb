# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Health check endpoint
      get 'health', to: 'health#show'

      # Devise handles sign_in/sign_out under api/v1/auth
      # Protected transactions endpoint
      resources :transactions, only: [:index, :create]
    end
  end

  # Devise API routes for users (JSON)
  devise_for :users,
             controllers: {
               sessions: 'api/v1/sessions',
               registrations: 'api/v1/registrations',
             },
             path: 'api/v1/auth',
             path_names: { sign_in: 'sign_in', sign_out: 'sign_out' }

  # Defines the root path route ("/")
  # root "posts#index"
end
