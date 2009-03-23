require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Admin::PagesController do
  describe 'index' do
    def do_get
      get :index
    end

    describe 'when no pages exist' do
      before :each do
        Page.delete_all
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make an empty page list available to the view' do
        do_get
        assigns[:pages].should == []
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

    describe 'when pages exist' do
      before :each do
        Page.delete_all
        @pages = Array.new(3) { |i| Page.generate!(:handle => "test handle #{10-i}") }
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make a list of the existing pages available to the view' do
        do_get
        assigns[:pages].collect(&:id).sort.should == @pages.collect(&:id).sort
      end
      
      it 'should sort the pages by handle' do
        do_get
        assigns[:pages].collect(&:id).should == @pages.sort_by(&:handle).collect(&:id)
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

  describe 'show' do
    def do_get
      get :show, :id => @id
    end

    it 'should redirect to the pages admin index' do
      do_get
      response.should redirect_to(admin_pages_path)
    end
  end

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

  describe 'edit' do
    describe 'when editing an existing page' do
      before :each do
        @page = Page.generate!
        @id = @page.id.to_s
      end

      def do_get
        get :edit, :id => @id
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make the found page available to the view' do
        do_get
        assigns[:page].id.should == @page.id
      end

      it 'should render the edit template' do
        do_get
        response.should render_template('admin/pages/edit')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
    end

    describe 'when attempting to edit a non-existent page' do
      it 'should result in a record not found exception' do
        lambda { get :edit, :id => 12345678 }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'update' do
    describe 'when given a valid page' do
      before :each do
        @page = Page.generate!
        @id = @page.id.to_s
      end

      def do_put
        put :update, :id => @id, :page => @page.attributes
      end

      it 'should not create a new page' do
        lambda { do_put }.should_not change(Page, :count)
      end

      it 'should update the page with the provided attributes' do
        do_put
        Page.find(@id).handle.should == @page.handle
      end

      it 'should redirect to the admin show view for the updated page' do
        do_put
        response.should redirect_to(admin_page_url(Page.first))
      end
    end

    describe 'when given an invalid page' do
      before :each do
        Page.delete_all
        Page.generate!(:handle => 'duplicate_handle')
        @page = Page.generate!
        @id = @page.id.to_s
      end

      def do_put
        put :update, :id => @id, :page => @page.attributes.merge('handle' => 'duplicate_handle')
      end

      it 'should be successful' do
        do_put
        response.should be_success
      end

      it 'should make the requested page available to the view' do
        do_put
        assigns[:page].id.should == @page.id
      end

      it 'should render the edit template' do
        do_put
        response.should render_template('edit')
      end

      it 'should use the admin layout' do
        do_put
        response.layout.should == 'layouts/admin'
      end
    end

    describe 'when attempting to update a non-existent page' do
      def do_put
        put :update, :id => 123456789, :page => { }
      end

      it 'should result in a record not found exception' do
        lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'destroy' do
    describe 'when given a valid page' do
      before :each do
        @page = Page.generate!
        @id = @page.id.to_s
      end

      def do_delete
        delete :destroy, :id => @id
      end

      it 'should destroy the specified page' do
        lambda { do_delete }.should change(Page, :count).by(-1)
      end

      it 'should redirect to the admin pages list' do
        do_delete
        response.should redirect_to(admin_pages_path)
      end
    end

    describe 'when attempting to destroy a non-existent page' do
      def do_delete
        delete :destroy, :id => 123456789
      end

      it 'should result in a record not found exception' do
        lambda { do_delete }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
