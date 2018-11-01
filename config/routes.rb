# frozen_string_literal: true

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  mount API::BaseAPI => '/api'
  mount GrapeSwaggerRails::Engine => '/swagger'

  root to: 'todo_lists#index'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :todo_lists do
    resources :todo_listships, only: %i[create edit update destroy]
  end
end
