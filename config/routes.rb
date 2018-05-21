Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  # root to: "todo_lists#index"
  post '/', to: "todo_lists#index"

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :todo_lists do
    resources :todo_listships, only: [:create, :destroy]
  end
end
