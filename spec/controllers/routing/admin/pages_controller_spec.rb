require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe Admin::PagesController, "#route_for" do
  it "should map { :controller => 'admin/pages', :action => 'index' } to /admin/pages" do
    route_for(:controller => "admin/pages", :action => "index").should == "/admin/pages"
  end
  
  it "should map { :controller => 'pages', :action => 'new' } to /admin/pages/new" do
    route_for(:controller => "admin/pages", :action => "new").should == "/admin/pages/new"
  end
  
  it "should map { :controller => 'pages', :action => 'show', :id => 1 } to /admin/pages/1" do
    route_for(:controller => "admin/pages", :action => "show", :id => '1').should == "/admin/pages/1"
  end
  
  it "should map { :controller => 'pages', :action => 'edit', :id => 1 } to /admin/pages/1/edit" do
    route_for(:controller => "admin/pages", :action => "edit", :id => '1').should == "/admin/pages/1/edit"
  end
  
  it "should map { :controller => 'pages', :action => 'update', :id => 1} to /admin/pages/1" do
    route_for(:controller => "admin/pages", :action => "update", :id => '1').should ==  { :path => "/admin/pages/1", :method => 'put' }
  end
  
  it "should map { :controller => 'pages', :action => 'destroy', :id => 1} to /admin/pages/1" do
    route_for(:controller => "admin/pages", :action => "destroy", :id => '1').should == { :path => "/admin/pages/1", :method => 'delete' }
  end
end

describe PagesController, "#params_from" do

  it "should generate params { :controller => 'pages', action => 'index' } from GET /admin/pages" do
    params_from(:get, "/admin/pages").should == {:controller => "admin/pages", :action => "index"}
  end
  
  it "should generate params { :controller => 'pages', action => 'new' } from GET /admin/pages/new" do
    params_from(:get, "/admin/pages/new").should == {:controller => "admin/pages", :action => "new"}
  end
  
  it "should generate params { :controller => 'pages', action => 'create' } from POST /admin/pages" do
    params_from(:post, "/admin/pages").should == {:controller => "admin/pages", :action => "create"}
  end
  
  it "should generate params { :controller => 'pages', action => 'show', id => '1' } from GET /admin/pages/1" do
    params_from(:get, "/admin/pages/1").should == {:controller => "admin/pages", :action => "show", :id => "1"}
  end
  
  it "should generate params { :controller => 'pages', action => 'edit', id => '1' } from GET /admin/pages/1;edit" do
    params_from(:get, "/admin/pages/1/edit").should == {:controller => "admin/pages", :action => "edit", :id => "1"}
  end
  
  it "should generate params { :controller => 'pages', action => 'update', id => '1' } from PUT /admin/pages/1" do
    params_from(:put, "/admin/pages/1").should == {:controller => "admin/pages", :action => "update", :id => "1"}
  end
  
  it "should generate params { :controller => 'pages', action => 'destroy', id => '1' } from DELETE /admin/pages/1" do
    params_from(:delete, "/admin/pages/1").should == {:controller => "admin/pages", :action => "destroy", :id => "1"}
  end
end
