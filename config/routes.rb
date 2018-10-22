Rails.application.routes.draw do
  root to: 'users#index'

  resources :users
  resources :markdown_readers, controller: :maps
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
