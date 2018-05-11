Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  root to: "home#index"

  devise_for :users

  resources :todo_lists do
    resources :todos
  end
end
