Rails.application.routes.draw do
  resources :adventure_locations
  resources :adventures, only: [:index]
  resources :visits
  resources :locations
  devise_for :users

  devise_scope :user do
    root to: "home#index"
  end

  get '*path', to: "guide#index"
end
