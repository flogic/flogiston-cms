require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe Admin::TemplatesController, "#route_for" do
  it "should map { :controller => 'admin/templates', :action => 'index' } to /admin/templates" do
    route_for(:controller => "admin/templates", :action => "index").should == "/admin/templates"
  end
  
  it "should map { :controller => 'templates', :action => 'new' } to /admin/templates/new" do
    route_for(:controller => "admin/templates", :action => "new").should == "/admin/templates/new"
  end
  
  it "should map { :controller => 'templates', :action => 'show', :id => 1 } to /admin/templates/1" do
    route_for(:controller => "admin/templates", :action => "show", :id => '1').should == "/admin/templates/1"
  end
  
  it "should map { :controller => 'templates', :action => 'edit', :id => 1 } to /admin/templates/1/edit" do
    route_for(:controller => "admin/templates", :action => "edit", :id => '1').should == "/admin/templates/1/edit"
  end
  
  it "should map { :controller => 'templates', :action => 'update', :id => 1} to /admin/templates/1" do
    route_for(:controller => "admin/templates", :action => "update", :id => '1').should ==  { :path => "/admin/templates/1", :method => 'put' }
  end
  
  it "should map { :controller => 'templates', :action => 'destroy', :id => 1} to /admin/templates/1" do
    route_for(:controller => "admin/templates", :action => "destroy", :id => '1').should == { :path => "/admin/templates/1", :method => 'delete' }
  end
end

describe Admin::TemplatesController, "#params_from" do

  it "should generate params { :controller => 'templates', action => 'index' } from GET /admin/templates" do
    params_from(:get, "/admin/templates").should == {:controller => "admin/templates", :action => "index"}
  end
  
  it "should generate params { :controller => 'templates', action => 'new' } from GET /admin/templates/new" do
    params_from(:get, "/admin/templates/new").should == {:controller => "admin/templates", :action => "new"}
  end
  
  it "should generate params { :controller => 'templates', action => 'create' } from POST /admin/templates" do
    params_from(:post, "/admin/templates").should == {:controller => "admin/templates", :action => "create"}
  end
  
  it "should generate params { :controller => 'templates', action => 'show', id => '1' } from GET /admin/templates/1" do
    params_from(:get, "/admin/templates/1").should == {:controller => "admin/templates", :action => "show", :id => "1"}
  end
  
  it "should generate params { :controller => 'templates', action => 'edit', id => '1' } from GET /admin/templates/1;edit" do
    params_from(:get, "/admin/templates/1/edit").should == {:controller => "admin/templates", :action => "edit", :id => "1"}
  end
  
  it "should generate params { :controller => 'templates', action => 'update', id => '1' } from PUT /admin/templates/1" do
    params_from(:put, "/admin/templates/1").should == {:controller => "admin/templates", :action => "update", :id => "1"}
  end
  
  it "should generate params { :controller => 'templates', action => 'destroy', id => '1' } from DELETE /admin/templates/1" do
    params_from(:delete, "/admin/templates/1").should == {:controller => "admin/templates", :action => "destroy", :id => "1"}
  end
end
