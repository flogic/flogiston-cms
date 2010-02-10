require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe Admin::TemplatesController do
  describe 'index' do
    def do_get
      get :index
    end

    describe 'when no templates exist' do
      before :each do
        Template.delete_all
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make an empty template list available to the view' do
        do_get
        assigns[:template_objs].should == []
      end

      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the template title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when templates exist' do
      before :each do
        Template.delete_all
        @template_objs = Array.new(3) { |i| Template.generate!(:handle => "test handle #{10-i}") }
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make a list of the existing templates available to the view' do
        do_get
        assigns[:template_objs].collect(&:id).sort.should == @template_objs.collect(&:id).sort
      end
      
      it 'should sort the templates by handle' do
        do_get
        assigns[:template_objs].collect(&:id).should == @template_objs.sort_by(&:handle).collect(&:id)
      end
      
      it 'should render the index view' do
        do_get
        response.should render_template('index')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the template title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'show' do
    before :each do
      @template_obj = Template.generate!
      @id = @template_obj.id.to_s
    end
    
    def do_get
      get :show, :id => @id
    end
    
    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should find the requested template' do
      Template.expects(:find).with(@id).returns(@template_obj)
      do_get
    end
    
    it 'should make the requested template available to the view' do
      do_get
      assigns[:template_obj].should == @template_obj
    end
    
    it 'should render the show template' do
      do_get
      response.should render_template('admin/templates/show')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
    
    it 'should set the template title' do
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

    it 'should make a new template available to the view' do
      do_get
      assigns[:template_obj].should be_new_record
    end

    it 'should render the new template' do
      do_get
      response.should render_template('admin/templates/new')
    end

    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
      
    it 'should set the template title' do
      do_get
      assigns[:title].should_not be_blank
    end    
  end

  describe 'create' do
    describe 'when given a valid template' do
      before :each do
        @template_obj = Template.spawn
      end

      def do_post
        post :create, :template => @template_obj.attributes
      end

      it 'should create a new template' do
        lambda { do_post }.should change(Template, :count).by(1)
      end

      it 'should use the provided attributes when creating the template' do
        Template.delete_all
        do_post
        Template.first.handle.should == @template_obj.handle
      end

      it 'should redirect to the admin show view for the new template' do
        Template.delete_all
        do_post
        response.should redirect_to(admin_template_url(Template.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_post
          post :create, :template => @template_obj.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested template available to the view' do
          do_post
          assigns[:template_obj].should be_kind_of(Template)
        end
        
        it 'should set the template attributes' do
          do_post
          assigns[:template_obj].contents.should == @new_contents
        end
        
        it 'should not save the template' do
          lambda { do_post }.should_not change(Template, :count)
        end

        it 'should render the new template' do
          do_post
          response.should render_template('new')
        end

        it 'should use the admin layout' do
          do_post
          response.layout.should == 'layouts/admin'
        end

        it 'should set the template title' do
          do_post
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_post
          post :create, :template => @template_obj.attributes, :preview => ''
        end
        
        it 'should create a new template' do
          lambda { do_post }.should change(Template, :count).by(1)
        end
      end
    end

    describe 'when given an invalid template' do
      before :each do
        Template.generate!(:handle => 'duplicate_handle')
        @template_obj = Template.spawn(:handle => 'duplicate_handle')
      end

      def do_post
        post :create, :template => @template_obj.attributes
      end

      it 'should be successful' do
        do_post
        response.should be_success
      end

      it 'should make a new template available to the view' do
        do_post
        assigns[:template_obj].should be_new_record
      end

      it 'should initialize the template with the given attributes' do
        do_post
        assigns[:template_obj].handle.should == @template_obj.handle
      end

      it 'should render the new template' do
        do_post
        response.should render_template('new')
      end

      it 'should use the admin layout' do
        do_post
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the template title' do
        do_post
        assigns[:title].should_not be_blank
      end
    end
  end

  describe 'edit' do
    describe 'when editing an existing template' do
      before :each do
        @template_obj = Template.generate!
        @id = @template_obj.id.to_s
      end

      def do_get
        get :edit, :id => @id
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should make the found template available to the view' do
        do_get
        assigns[:template_obj].id.should == @template_obj.id
      end

      it 'should render the edit template' do
        do_get
        response.should render_template('admin/templates/edit')
      end

      it 'should use the admin layout' do
        do_get
        response.layout.should == 'layouts/admin'
      end

      it 'should set the template title' do
        do_get
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to edit a non-existent template' do
      it 'should result in a record not found exception' do
        lambda { get :edit, :id => 12345678 }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'update' do
    describe 'when given a valid template' do
      before :each do
        @template_obj = Template.generate!
        @id = @template_obj.id.to_s
        @new_handle = 'some_unused_handle_I_really_hope'
      end

      def do_put
        put :update, :id => @id, :template => @template_obj.attributes.merge('handle' => @new_handle)
      end

      it 'should not create a new template' do
        lambda { do_put }.should_not change(Template, :count)
      end

      it 'should update the template with the provided attributes' do
        do_put
        Template.find(@id).handle.should == @new_handle
      end

      it 'should redirect to the admin show view for the updated template' do
        do_put
        response.should redirect_to(admin_template_url(Template.first))
      end
      
      describe 'and previewing' do
        before :each do
          @new_contents = 'new contents go here'
        end
        
        def do_put
          put :update, :id => @id, :template => @template_obj.attributes.merge('contents' => @new_contents), :preview => true
        end
        
        it 'should make the requested template available to the view' do
          do_put
          assigns[:template_obj].id.should == @template_obj.id
        end
        
        it 'should set the template attributes' do
          do_put
          assigns[:template_obj].contents.should == @new_contents
        end
        
        it 'should not save the attributes' do
          do_put
          Template.find(@id).contents.should_not == @new_contents
        end

        it 'should render the edit template' do
          do_put
          response.should render_template('edit')
        end

        it 'should use the admin layout' do
          do_put
          response.layout.should == 'layouts/admin'
        end

        it 'should set the template title' do
          do_put
          assigns[:title].should_not be_blank
        end
      end
      
      describe 'with an empty preview parameter' do
        def do_put
          put :update, :id => @id, :template => @template_obj.attributes.merge('handle' => @new_handle), :preview => ''
        end
        
        it 'should update the template with the provided attributes' do
          do_put
          Template.find(@id).handle.should == @new_handle
        end
      end
    end

    describe 'when given an invalid template' do
      before :each do
        Template.delete_all
        Template.generate!(:handle => 'duplicate_handle')
        @template_obj = Template.generate!
        @id = @template_obj.id.to_s
      end

      def do_put
        put :update, :id => @id, :template => @template_obj.attributes.merge('handle' => 'duplicate_handle')
      end

      it 'should be successful' do
        do_put
        response.should be_success
      end

      it 'should make the requested template available to the view' do
        do_put
        assigns[:template_obj].id.should == @template_obj.id
      end

      it 'should render the edit template' do
        do_put
        response.should render_template('edit')
      end

      it 'should use the admin layout' do
        do_put
        response.layout.should == 'layouts/admin'
      end
      
      it 'should set the template title' do
        do_put
        assigns[:title].should_not be_blank
      end
    end

    describe 'when attempting to update a non-existent template' do
      def do_put
        put :update, :id => 123456789, :template => { }
      end

      it 'should result in a record not found exception' do
        lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'destroy' do
    describe 'when given a valid template' do
      before :each do
        @template_obj = Template.generate!
        @id = @template_obj.id.to_s
      end

      def do_delete
        delete :destroy, :id => @id
      end

      it 'should destroy the specified template' do
        lambda { do_delete }.should change(Template, :count).by(-1)
      end

      it 'should redirect to the admin templates list' do
        do_delete
        response.should redirect_to(admin_templates_path)
      end
    end

    describe 'when attempting to destroy a non-existent template' do
      def do_delete
        delete :destroy, :id => 123456789
      end

      it 'should result in a record not found exception' do
        lambda { do_delete }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
