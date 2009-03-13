ActionController::Routing::Routes.draw do |map|
  map.resources :pages

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'pages', :action => 'show'
end
