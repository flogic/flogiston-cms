ActionController::Routing::Routes.draw do |map|
  map.resources :pages

  map.namespace :admin do |admin|
    admin.resources :pages
    admin.resources :snippets
    admin.resources :templates
  end
end
