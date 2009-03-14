require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Admin::PagesController do
  describe 'new' do
    def do_get
      get :new
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should make a new page available to the view' do
      do_get
      assigns[:page].should be_new_record
    end

    it 'should render the new template' do
      do_get
      response.should render_template('admin/pages/new')
    end

    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
  end
end
