require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe ApplicationController, 'dynamically determining the layout' do
  before do
    Layout.delete_all
    @layout = Layout.generate!(:default => true)
  end

  class ApplicationController
    def site_test
    end
  end

  it 'should use the default layout object for the layout' do
    get :site_test
    expected = "<Layout '#{@layout.handle}'>"
    response.layout.should == expected
  end

  it "should fall back to 'application' if there is no default layout object" do
    @layout.update_attributes!(:default => false)
    get :site_test
    response.layout.should == 'layouts/application'
  end

  it "should fall back to 'application' if there are no layout objects" do
    Layout.delete_all
    get :site_test
    response.layout.should == 'layouts/application'
  end
end
