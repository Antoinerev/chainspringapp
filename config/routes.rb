Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get '/signout', to: 'devise/sessions#destroy', as: :signout
  end

  root to: 'users#show'

  resources :users
  resources :markdown_readers, controller: :maps

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'map/build', to: 'maps#build_map'
      get 'map/search', to: 'maps#search'
      post 'map/addki', to: 'maps#create_ki'
      post 'map/editki', to: 'maps#update_ki'

      resources :knowledge_items, path: "references", except: [:index, :show]

      resources :domains, path: "topics", except: [:index, :show]
    end
  end
end
