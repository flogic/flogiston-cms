require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Admin::SnippetsController do
  describe 'index' do
    def do_get
      get :index
    end

    describe 'when no snippets exist' do
      before :each do
        Snippet.delete_all
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make an empty snippet list available to the view' do
        do_get
        assigns[:snippets].should == []
      end

      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the snippet title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when snippets exist' do
      before :each do
        Snippet.delete_all
        @snippets = Array.new(3) { |i| Snippet.generate!(:handle => "test handle #{10-i}") }
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make a list of the existing snippets available to the view' do
        do_get
        assigns[:snippets].collect(&:id).sort.should == @snippets.collect(&:id).sort
      end
      
      it 'should sort the snippets by handle' do
        do_get
        assigns[:snippets].collect(&:id).should == @snippets.sort_by(&:handle).collect(&:id)
      end
      
      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the snippet title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'show' do
    def do_get
      get :show, :id => @id
    end

    it 'should redirect to the snippets admin index' do
      do_get
      response.should redirect_to(admin_snippets_path)
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

    it 'should make a new snippet available to the view' do
      do_get
      assigns[:snippet].should be_new_record
    end

    it 'should render the new template' do
      do_get
      response.should render_template('admin/snippets/new')
    end

    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
      
    it 'should set the snippet title' do
      do_get
      assigns[:title].should_not be_blank
    end    
  end

  describe 'create' do
    describe 'when given a valid snippet' do
      before :each do
        @snippet = Snippet.spawn
      end

      def do_post
        post :create, :snippet => @snippet.attributes
      end

      it 'should create a new snippet' do
        lambda { do_post }.should change(Snippet, :count).by(1)
      end

      it 'should use the provided attributes when creating the snippet' do
        Snippet.delete_all
        do_post
        Snippet.first.handle.should == @snippet.handle
      end

      it 'should redirect to the admin show view for the new snippet' do
        Snippet.delete_all
        do_post
        response.should redirect_to(admin_snippet_url(Snippet.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_post
          post :create, :snippet => @snippet.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested snippet available to the view' do
          do_post
          assigns[:snippet].should be_kind_of(Snippet)
        end
        
        it 'should set the snippet attributes' do
          do_post
          assigns[:snippet].contents.should == @new_contents
        end
        
        it 'should not save the snippet' do
          lambda { do_post }.should_not change(Snippet, :count)
        end

        it 'should render the new template' do
          do_post
          response.should render_template('new')
        end

        it 'should use the admin layout' do
          do_post
          response.layout.should == 'layouts/admin'
        end

        it 'should set the snippet title' do
          do_post
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_post
          post :create, :snippet => @snippet.attributes, :preview => ''
        end
        
        it 'should create a new snippet' do
          lambda { do_post }.should change(Snippet, :count).by(1)
        end
      end
    end

    describe 'when given an invalid snippet' do
      before :each do
        Snippet.generate!(:handle => 'duplicate_handle')
        @snippet = Snippet.spawn(:handle => 'duplicate_handle')
      end

      def do_post
        post :create, :snippet => @snippet.attributes
      end

      it 'should be successful' do
        do_post
        response.should be_success
      end

      it 'should make a new snippet available to the view' do
        do_post
        assigns[:snippet].should be_new_record
      end

      it 'should initialize the snippet with the given attributes' do
        do_post
        assigns[:snippet].handle.should == @snippet.handle
      end

      it 'should render the new template' do
        do_post
        response.should render_template('new')
      end

      it 'should use the admin layout' do
        do_post
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the snippet title' do
        do_post
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'edit' do
    describe 'when editing an existing snippet' do
      before :each do
        @snippet = Snippet.generate!
        @id = @snippet.id.to_s
      end

      def do_get
        get :edit, :id => @id
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make the found snippet available to the view' do
        do_get
        assigns[:snippet].id.should == @snippet.id
      end

      it 'should render the edit template' do
        do_get
        response.should render_template('admin/snippets/edit')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end

      it 'should set the snippet title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to edit a non-existent snippet' do
      it 'should result in a record not found exception' do
        lambda { get :edit, :id => 12345678 }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'update' do
    describe 'when given a valid snippet' do
      before :each do
        @snippet = Snippet.generate!
        @id = @snippet.id.to_s
        @new_handle = 'some_unused_handle_I_really_hope'
      end

      def do_put
        put :update, :id => @id, :snippet => @snippet.attributes.merge('handle' => @new_handle)
      end

      it 'should not create a new snippet' do
        lambda { do_put }.should_not change(Snippet, :count)
      end

      it 'should update the snippet with the provided attributes' do
        do_put
        Snippet.find(@id).handle.should == @new_handle
      end

      it 'should redirect to the admin show view for the updated snippet' do
        do_put
        response.should redirect_to(admin_snippet_url(Snippet.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_put
          put :update, :id => @id, :snippet => @snippet.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested snippet available to the view' do
          do_put
          assigns[:snippet].id.should == @snippet.id
        end
        
        it 'should set the snippet attributes' do
          do_put
          assigns[:snippet].contents.should == @new_contents
        end
        
        it 'should not save the attributes' do
          do_put
          Snippet.find(@id).contents.should_not == @new_contents
        end

        it 'should render the edit template' do
          do_put
          response.should render_template('edit')
        end

        it 'should use the admin layout' do
          do_put
          response.layout.should == 'layouts/admin'
        end

        it 'should set the snippet title' do
          do_put
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_put
          put :update, :id => @id, :snippet => @snippet.attributes.merge('handle' => @new_handle), :preview => ''
        end
        
        it 'should update the snippet with the provided attributes' do
          do_put
          Snippet.find(@id).handle.should == @new_handle
        end
      end
    end

    describe 'when given an invalid snippet' do
      before :each do
        Snippet.delete_all
        Snippet.generate!(:handle => 'duplicate_handle')
        @snippet = Snippet.generate!
        @id = @snippet.id.to_s
      end

      def do_put
        put :update, :id => @id, :snippet => @snippet.attributes.merge('handle' => 'duplicate_handle')
      end

      it 'should be successful' do
        do_put
        response.should be_success
      end

      it 'should make the requested snippet available to the view' do
        do_put
        assigns[:snippet].id.should == @snippet.id
      end

      it 'should render the edit template' do
        do_put
        response.should render_template('edit')
      end

      it 'should use the admin layout' do
        do_put
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the snippet title' do
        do_put
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to update a non-existent snippet' do
      def do_put
        put :update, :id => 123456789, :snippet => { }
      end

      it 'should result in a record not found exception' do
        lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'destroy' do
    describe 'when given a valid snippet' do
      before :each do
        @snippet = Snippet.generate!
        @id = @snippet.id.to_s
      end

      def do_delete
        delete :destroy, :id => @id
      end

      it 'should destroy the specified snippet' do
        lambda { do_delete }.should change(Snippet, :count).by(-1)
      end

      it 'should redirect to the admin snippets list' do
        do_delete
        response.should redirect_to(admin_snippets_path)
      end
    end

    describe 'when attempting to destroy a non-existent snippet' do
      def do_delete
        delete :destroy, :id => 123456789
      end

      it 'should result in a record not found exception' do
        lambda { do_delete }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
