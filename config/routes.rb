Rails.application.routes.draw do
  resources :adventure_locations
  resources :adventures, only: [:index]
  resources :visits
  resources :locations
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
  get '*path', to: "guide#index"
end
