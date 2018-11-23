Rails.application.routes.draw do
  devise_for :users
  root to: 'users#show'

  resources :users
  resources :markdown_readers, controller: :maps

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # resources :spaces, only: :index
      get 'map/build', to: 'maps#build_map'
      get 'map/search', to: 'maps#search'
      post 'map/update', to: 'maps#update'
    end
  end
end
