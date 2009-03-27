# flogiston routes
# You want to keep this stuff after your main routes. Unless, of course, you like the idea 
# of this handy-dandy *path route taking precedence over other, more sensible routes.
ActionController::Routing::Routes.draw do |map|
  map.connect '*path', :controller => 'pages', :action => 'show'
end
