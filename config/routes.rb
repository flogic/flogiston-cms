ActionController::Routing::Routes.draw do |map|
  map.resources :pages

  map.namespace :admin do |admin|
    admin.resources :pages
    admin.resources :snippets
    admin.resources :templates
    admin.resources :layouts, :member => { :default => :put }
  end
end
