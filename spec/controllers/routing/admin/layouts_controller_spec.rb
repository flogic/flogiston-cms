require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe Admin::LayoutsController, "#route_for" do
  it "should map { :controller => 'admin/layouts', :action => 'index' } to /admin/layouts" do
    route_for(:controller => "admin/layouts", :action => "index").should == "/admin/layouts"
  end
  
  it "should map { :controller => 'layouts', :action => 'new' } to /admin/layouts/new" do
    route_for(:controller => "admin/layouts", :action => "new").should == "/admin/layouts/new"
  end
  
  it "should map { :controller => 'layouts', :action => 'show', :id => 1 } to /admin/layouts/1" do
    route_for(:controller => "admin/layouts", :action => "show", :id => '1').should == "/admin/layouts/1"
  end
  
  it "should map { :controller => 'layouts', :action => 'edit', :id => 1 } to /admin/layouts/1/edit" do
    route_for(:controller => "admin/layouts", :action => "edit", :id => '1').should == "/admin/layouts/1/edit"
  end
  
  it "should map { :controller => 'layouts', :action => 'update', :id => 1} to /admin/layouts/1" do
    route_for(:controller => "admin/layouts", :action => "update", :id => '1').should ==  { :path => "/admin/layouts/1", :method => 'put' }
  end
  
  it "should map { :controller => 'layouts', :action => 'destroy', :id => 1} to /admin/layouts/1" do
    route_for(:controller => "admin/layouts", :action => "destroy", :id => '1').should == { :path => "/admin/layouts/1", :method => 'delete' }
  end

  it "should map { :controller => 'layouts', :action => 'default', :id => 1} to /admin/layouts/1/default" do
    route_for(:controller => "admin/layouts", :action => "default", :id => '1').should ==  { :path => "/admin/layouts/1/default", :method => 'put' }
  end
end

describe Admin::LayoutsController, "#params_from" do

  it "should generate params { :controller => 'layouts', action => 'index' } from GET /admin/layouts" do
    params_from(:get, "/admin/layouts").should == {:controller => "admin/layouts", :action => "index"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'new' } from GET /admin/layouts/new" do
    params_from(:get, "/admin/layouts/new").should == {:controller => "admin/layouts", :action => "new"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'create' } from POST /admin/layouts" do
    params_from(:post, "/admin/layouts").should == {:controller => "admin/layouts", :action => "create"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'show', id => '1' } from GET /admin/layouts/1" do
    params_from(:get, "/admin/layouts/1").should == {:controller => "admin/layouts", :action => "show", :id => "1"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'edit', id => '1' } from GET /admin/layouts/1/edit" do
    params_from(:get, "/admin/layouts/1/edit").should == {:controller => "admin/layouts", :action => "edit", :id => "1"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'update', id => '1' } from PUT /admin/layouts/1" do
    params_from(:put, "/admin/layouts/1").should == {:controller => "admin/layouts", :action => "update", :id => "1"}
  end
  
  it "should generate params { :controller => 'layouts', action => 'destroy', id => '1' } from DELETE /admin/layouts/1" do
    params_from(:delete, "/admin/layouts/1").should == {:controller => "admin/layouts", :action => "destroy", :id => "1"}
  end

  it "should generate params { :controller => 'layouts', action => 'default', id => '1' } from PUT /admin/layouts/1/default" do
    params_from(:put, "/admin/layouts/1/default").should == {:controller => "admin/layouts", :action => "default", :id => "1"}
  end
end
