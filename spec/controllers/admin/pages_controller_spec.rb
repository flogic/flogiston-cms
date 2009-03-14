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

  describe 'create' do
    describe 'when given a valid page' do
      before :each do
        @page = Page.spawn
      end

      def do_post
        post :create, :page => @page.attributes
      end

      it 'should create a new page' do
        lambda { do_post }.should change(Page, :count).by(1)
      end

      it 'should use the provided attributes when creating the page' do
        Page.delete_all
        do_post
        Page.first.handle.should == @page.handle
      end

      it 'should redirect to the admin show view for the new page' do
        Page.delete_all
        do_post
        response.should redirect_to(admin_page_url(Page.first))
      end
    end

    describe 'when given an invalid page' do
      before :each do
        Page.generate!(:handle => 'duplicate_handle')
        @page = Page.spawn(:handle => 'duplicate_handle')
      end

      def do_post
        post :create, :page => @page.attributes
      end

      it 'should be successful' do
        do_post
        response.should be_success
      end

      it 'should make a new page available to the view' do
        do_post
        assigns[:page].should be_new_record
      end
      
      it 'should initialize the page with the given attributes' do
        do_post
        assigns[:page].handle.should == @page.handle
      end
      
      it 'should render the new template' do
        do_post
        response.should render_template('new')
      end
      
      it 'should use the admin layout' do
        do_post
        response.layout.should == 'layouts/admin'
      end
    end
  end
end
