require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe AdminController do
  describe 'when integrating' do
      
    integrate_views
  
    describe 'index' do
      it 'should be successful' do
        get :index
        response.should be_success
      end
  
      it 'should include an admin pages link' do
        get :index
        response.should have_tag('a[href=?]', admin_pages_path)
      end
    end
  end
end
