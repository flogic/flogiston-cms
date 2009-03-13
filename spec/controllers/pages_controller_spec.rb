require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe PagesController do
  describe 'show' do
    describe 'when an id is specified' do
      describe 'which matches an existing Page id' do
        before :each do
          @page = Page.generate!
          @id = @page.id.to_s
          Page.stubs(:find).returns(@page)
        end

        def do_get
          get :show, :id => @id
        end

        it 'should look up the requested page' do
          Page.expects(:find).with(@id).returns(@page)
          do_get
        end

        it 'should make the requested page available to the view' do
          do_get
          assigns[:page].should == @page
        end

        it 'should be successful' do
          do_get
          response.should be_success
        end

        it 'should render the show view' do
          do_get
          response.should render_template('show')
        end

        it 'should use the default layout' do
          do_get
          response.layout.should be_nil
        end
      end

      describe 'which does not match a Page id' do
        def do_get
          get :show, :id => 349875634567
        end

        it 'should throw a record not found exception' do
          lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe 'when a path is specified' do
    describe 'which matches a page handle' do
      before :each do
        @handle = 'test_handle'
        @page = Page.generate!(:handle => @handle)
      end

      def do_get
        get :show, :path => [ @handle ]
      end

      it 'should look up the requested page by handle' do
        Page.expects(:find_by_handle!).with(@handle).returns(@page)
        do_get
      end

      it 'should make the requested page available to the view' do
        do_get
        assigns[:page].should == @page
      end

      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should render the show view' do
        do_get
        response.should render_template('show')
      end

      it 'should use the default layout' do
        do_get
        response.layout.should be_nil
      end
    end

    describe 'which does not match a page handle' do
      def do_get
        get :show, :path => ['nonexistant_handle']
      end

      it 'should throw a record not found exception' do
        lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'when neither an id or a path is specified' do
    def do_get
      get :show
    end

    it 'should throw a record not found exception' do
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
