Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :services, only: %i[index show] do
    resources :reviews, only: %i[new create]
  end

  namespace :suppliers do
    resources :services
    resources :dashboard, only: %i[index]
    resources :orders, only: %i[index]

    # BLOQUE PARA AGENDA PROVEEDOR
    resources :availabilities, only: [:index, :create, :destroy]
    resources :blackouts,      only: [:index, :create, :destroy]
  end

  resources :orders, only: %i[new create edit update show] do
    resources :reviews, only: %i[new create]
  end

  resources :dashboard, only: %i[index]

  # BLOQUE AGENDA PROVEEDOR
  resources :services, only: [:show] do
    get :available_slots, on: :member
  end

  resources :chats, only: [:index, :create]

  resources :chats, only: [:show] do
    resources :messages, only: [:create]
  end

end
