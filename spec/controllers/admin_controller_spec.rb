require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe AdminController do
  describe 'index' do
    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end
    
    it 'should render the index view' do
        do_get
      response.should render_template('index')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
  end
end
