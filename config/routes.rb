Rails.application.routes.draw do
  root to: "home#index"
  get 'about', to: "home#about"
  get 'search', to: "home#search"
  post 'search', to: "home#search"

  devise_for :users, class_name: 'FormUser', :controllers => { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations', invitations: 'invitations'}
  devise_scope :user do
    get '/users/auth/:provider/upgrade' => 'omniauth_callbacks#upgrade', as: :user_omniauth_upgrade
    get '/users/auth/:provider/setup', :to => 'omniauth_callbacks#setup'
    post 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
  end
  
  resources :communities do
    resources :memberships
    resources :projects do
      resources :pledges
      resources :musters
    end
    member do
      get :application
      post :apply
      get :applications
      post :approve
    end
  end

  resources :users do
    resources :check_ins
  end

  resources :labors do
    resources :ratings
  end

  resources :links
  resources :posts
  resources :images
end
