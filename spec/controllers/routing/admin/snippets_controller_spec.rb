require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe Admin::SnippetsController, "#route_for" do
  it "should map { :controller => 'admin/snippets', :action => 'index' } to /admin/snippets" do
    route_for(:controller => "admin/snippets", :action => "index").should == "/admin/snippets"
  end
  
  it "should map { :controller => 'snippets', :action => 'new' } to /admin/snippets/new" do
    route_for(:controller => "admin/snippets", :action => "new").should == "/admin/snippets/new"
  end
  
  it "should map { :controller => 'snippets', :action => 'show', :id => 1 } to /admin/snippets/1" do
    route_for(:controller => "admin/snippets", :action => "show", :id => '1').should == "/admin/snippets/1"
  end
  
  it "should map { :controller => 'snippets', :action => 'edit', :id => 1 } to /admin/snippets/1/edit" do
    route_for(:controller => "admin/snippets", :action => "edit", :id => '1').should == "/admin/snippets/1/edit"
  end
  
  it "should map { :controller => 'snippets', :action => 'update', :id => 1} to /admin/snippets/1" do
    route_for(:controller => "admin/snippets", :action => "update", :id => '1').should ==  { :path => "/admin/snippets/1", :method => 'put' }
  end
  
  it "should map { :controller => 'snippets', :action => 'destroy', :id => 1} to /admin/snippets/1" do
    route_for(:controller => "admin/snippets", :action => "destroy", :id => '1').should == { :path => "/admin/snippets/1", :method => 'delete' }
  end
end

describe Admin::SnippetsController, "#params_from" do

  it "should generate params { :controller => 'snippets', action => 'index' } from GET /admin/snippets" do
    params_from(:get, "/admin/snippets").should == {:controller => "admin/snippets", :action => "index"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'new' } from GET /admin/snippets/new" do
    params_from(:get, "/admin/snippets/new").should == {:controller => "admin/snippets", :action => "new"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'create' } from POST /admin/snippets" do
    params_from(:post, "/admin/snippets").should == {:controller => "admin/snippets", :action => "create"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'show', id => '1' } from GET /admin/snippets/1" do
    params_from(:get, "/admin/snippets/1").should == {:controller => "admin/snippets", :action => "show", :id => "1"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'edit', id => '1' } from GET /admin/snippets/1;edit" do
    params_from(:get, "/admin/snippets/1/edit").should == {:controller => "admin/snippets", :action => "edit", :id => "1"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'update', id => '1' } from PUT /admin/snippets/1" do
    params_from(:put, "/admin/snippets/1").should == {:controller => "admin/snippets", :action => "update", :id => "1"}
  end
  
  it "should generate params { :controller => 'snippets', action => 'destroy', id => '1' } from DELETE /admin/snippets/1" do
    params_from(:delete, "/admin/snippets/1").should == {:controller => "admin/snippets", :action => "destroy", :id => "1"}
  end
end
