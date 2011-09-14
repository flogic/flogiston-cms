require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Admin::LayoutsController do
  describe 'index' do
    def do_get
      get :index
    end

    describe 'when no layouts exist' do
      before :each do
        Layout.delete_all
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make an empty layout list available to the view' do
        do_get
        assigns[:layouts].should == []
      end

      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the layout title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when layouts exist' do
      before :each do
        Layout.delete_all
        @layouts = Array.new(3) { |i| Layout.generate!(:handle => "test handle #{10-i}") }
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make a list of the existing layouts available to the view' do
        do_get
        assigns[:layouts].collect(&:id).sort.should == @layouts.collect(&:id).sort
      end
      
      it 'should sort the layouts by handle' do
        do_get
        assigns[:layouts].collect(&:id).should == @layouts.sort_by(&:handle).collect(&:id)
      end
      
      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the layout title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'show' do
    before :each do
      @layout = Layout.generate!
      @id = @layout.id.to_s
    end
    
    def do_get
      get :show, :id => @id
    end
    
    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find the requested layout' do
      Layout.expects(:find).with(@id).returns(@layout)
      do_get
    end
    
    it 'should make the requested layout available to the view' do
      do_get
      assigns[:layout].should == @layout
    end
    
    it 'should render the show layout' do
      do_get
      response.should render_template('admin/layouts/show')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
    
    it 'should set the layout title' do
      do_get
      assigns[:title].should_not be_blank
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

    it 'should make a new layout available to the view' do
      do_get
      assigns[:layout].should be_new_record
    end

    it 'should render the new layout' do
      do_get
      response.should render_template('admin/layouts/new')
    end

    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
      
    it 'should set the layout title' do
      do_get
      assigns[:title].should_not be_blank
    end    
  end

  describe 'create' do
    describe 'when given a valid layout' do
      before :each do
        @layout = Layout.spawn
      end

      def do_post
        post :create, :layout => @layout.attributes
      end

      it 'should create a new layout' do
        lambda { do_post }.should change(Layout, :count).by(1)
      end

      it 'should use the provided attributes when creating the layout' do
        Layout.delete_all
        do_post
        Layout.first.handle.should == @layout.handle
      end

      it 'should redirect to the admin show view for the new layout' do
        Layout.delete_all
        do_post
        response.should redirect_to(admin_layout_url(Layout.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_post
          post :create, :layout => @layout.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested layout available to the view' do
          do_post
          assigns[:layout].should be_kind_of(Layout)
        end
        
        it 'should set the layout attributes' do
          do_post
          assigns[:layout].contents.should == @new_contents
        end
        
        it 'should not save the layout' do
          lambda { do_post }.should_not change(Layout, :count)
        end

        it 'should render the new layout' do
          do_post
          response.should render_template('new')
        end

        it 'should use the admin layout' do
          do_post
          response.layout.should == 'layouts/admin'
        end

        it 'should set the layout title' do
          do_post
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_post
          post :create, :layout => @layout.attributes, :preview => ''
        end
        
        it 'should create a new layout' do
          lambda { do_post }.should change(Layout, :count).by(1)
        end
      end
    end

    describe 'when given an invalid layout' do
      before :each do
        Layout.generate!(:handle => 'duplicate_handle')
        @layout = Layout.spawn(:handle => 'duplicate_handle')
      end

      def do_post
        post :create, :layout => @layout.attributes
      end

      it 'should be successful' do
        do_post
        response.should be_success
      end

      it 'should make a new layout available to the view' do
        do_post
        assigns[:layout].should be_new_record
      end

      it 'should initialize the layout with the given attributes' do
        do_post
        assigns[:layout].handle.should == @layout.handle
      end

      it 'should render the new layout' do
        do_post
        response.should render_template('new')
      end

      it 'should use the admin layout' do
        do_post
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the layout title' do
        do_post
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'edit' do
    describe 'when editing an existing layout' do
      before :each do
        @layout = Layout.generate!
        @id = @layout.id.to_s
      end

      def do_get
        get :edit, :id => @id
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make the found layout available to the view' do
        do_get
        assigns[:layout].id.should == @layout.id
      end

      it 'should render the edit layout' do
        do_get
        response.should render_template('admin/layouts/edit')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end

      it 'should set the layout title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to edit a non-existent layout' do
      it 'should result in a record not found exception' do
        lambda { get :edit, :id => 12345678 }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'update' do
    describe 'when given a valid layout' do
      before :each do
        @layout = Layout.generate!
        @id = @layout.id.to_s
        @new_handle = 'some_unused_handle_I_really_hope'
      end

      def do_put
        put :update, :id => @id, :layout => @layout.attributes.merge('handle' => @new_handle)
      end

      it 'should not create a new layout' do
        lambda { do_put }.should_not change(Layout, :count)
      end

      it 'should update the layout with the provided attributes' do
        do_put
        Layout.find(@id).handle.should == @new_handle
      end

      it 'should redirect to the admin show view for the updated layout' do
        do_put
        response.should redirect_to(admin_layout_url(Layout.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_put
          put :update, :id => @id, :layout => @layout.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested layout available to the view' do
          do_put
          assigns[:layout].id.should == @layout.id
        end
        
        it 'should set the layout attributes' do
          do_put
          assigns[:layout].contents.should == @new_contents
        end
        
        it 'should not save the attributes' do
          do_put
          Layout.find(@id).contents.should_not == @new_contents
        end

        it 'should render the edit layout' do
          do_put
          response.should render_template('edit')
        end

        it 'should use the admin layout' do
          do_put
          response.layout.should == 'layouts/admin'
        end

        it 'should set the layout title' do
          do_put
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_put
          put :update, :id => @id, :layout => @layout.attributes.merge('handle' => @new_handle), :preview => ''
        end
        
        it 'should update the layout with the provided attributes' do
          do_put
          Layout.find(@id).handle.should == @new_handle
        end
      end
    end

    describe 'when given an invalid layout' do
      before :each do
        Layout.delete_all
        Layout.generate!(:handle => 'duplicate_handle')
        @layout = Layout.generate!
        @id = @layout.id.to_s
      end

      def do_put
        put :update, :id => @id, :layout => @layout.attributes.merge('handle' => 'duplicate_handle')
      end

      it 'should be successful' do
        do_put
        response.should be_success
      end

      it 'should make the requested layout available to the view' do
        do_put
        assigns[:layout].id.should == @layout.id
      end

      it 'should render the edit layout' do
        do_put
        response.should render_template('edit')
      end

      it 'should use the admin layout' do
        do_put
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the layout title' do
        do_put
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to update a non-existent layout' do
      def do_put
        put :update, :id => 123456789, :layout => { }
      end

      it 'should result in a record not found exception' do
        lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'destroy' do
    describe 'when given a valid layout' do
      before :each do
        @layout = Layout.generate!
        @id = @layout.id.to_s
      end

      def do_delete
        delete :destroy, :id => @id
      end

      it 'should destroy the specified layout' do
        lambda { do_delete }.should change(Layout, :count).by(-1)
      end

      it 'should redirect to the admin layouts list' do
        do_delete
        response.should redirect_to(admin_layouts_path)
      end
    end

    describe 'when attempting to destroy a non-existent layout' do
      def do_delete
        delete :destroy, :id => 123456789
      end

      it 'should result in a record not found exception' do
        lambda { do_delete }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
