Rails.application.routes.draw do
  root to: 'users#index'

  resources :users
  resources :markdown_readers, controller: :maps

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # resources :spaces, only: :index
      get 'map/build', to: 'maps#build_map'
      get 'map/search', to: 'maps#search'
    end
  end
end
