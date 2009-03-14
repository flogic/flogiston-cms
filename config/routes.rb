ActionController::Routing::Routes.draw do |map|
  map.resources :pages

  map.namespace :admin do |admin|
    admin.resources :pages
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'pages', :action => 'show'
end
