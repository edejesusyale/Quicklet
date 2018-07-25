Rails.application.routes.draw do
  get 'search/index'
  get 'search/search'
  #post 'search/search'

  match 'search/search', to: 'search#search', via: [:get, :post]

  root 'search#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
