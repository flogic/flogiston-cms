require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Page do
  before :each do
    @page = Page.new
  end

  describe 'attributes' do
    it 'should have a title' do
      @page.should respond_to(:title)
    end

    it 'should allow setting and retrieving the title' do
      @page.title = 'Test Title'
      @page.save!
      @page.reload.title.should == 'Test Title'
    end

    it 'should have a handle' do
      @page.should respond_to(:handle)
    end

    it 'should allow setting and retrieving the handle' do
      @page.handle = 'test_handle'
      @page.save!
      @page.reload.handle.should == 'test_handle'
    end

    it 'should have a contents' do
      @page.should respond_to(:contents)
    end

    it 'should allow setting and retrieving the contents' do
      @page.contents = 'Test Contents'
      @page.save!
      @page.reload.contents.should == 'Test Contents'
    end
  end

  describe 'validations' do
    it 'should require handles to be unique' do
      Page.generate!(:handle => 'duplicate handle')
      dup = Page.generate(:handle => 'duplicate handle')
      dup.errors.should be_invalid(:handle)
    end
    
    it 'should check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Page.expects(:valid_handle?).with(handle).returns(true)
      Page.generate(:handle => handle)
    end
    
    it 'should require the handle to be valid according to the class' do
      Page.stubs(:valid_handle?).returns(false)
      page = Page.generate(:handle => 'some_handle')
      page.errors.should be_invalid(:handle)
    end
    
    it 'should accept handles that are valid according to the class' do
      Page.stubs(:valid_handle?).returns(true)
      page = Page.generate(:handle => 'some_handle')
      page.errors.should_not be_invalid(:handle)
    end
  end
  
  describe 'as a class' do
    it 'should be able to check if a given handle is valid' do
      Page.should respond_to(:valid_handle?)
    end
    
    describe 'checking if a given handle is valid' do
      before :each do
        @handle = '/some_handle'
        ActionController::Routing::Routes.stubs(:recognize_path).returns({})
      end
      
      it 'should accept a handle' do
        lambda { Page.valid_handle?(@handle) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a handle' do
        lambda { Page.valid_handle? }.should raise_error(ArgumentError)
      end
      
      it 'should ask the routes to recognize the handle' do
        ActionController::Routing::Routes.expects(:recognize_path).with(@handle).returns({})
        Page.valid_handle?(@handle)
      end
      
      it 'should return false if the handle recognization is for an existent controller and action' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'something', :action => 'index' })
        Page.valid_handle?(@handle).should be(false)
      end
      
      it 'should return false if the handle recognization is for the pages controller and has no path' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'pages', :action => 'show', :id => '1' })
        Page.valid_handle?(@handle).should be(false)
      end
      
      it 'should return true if the handle recognization is for the pages controller and has a path' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'pages', :action => 'show', :path => ['some_handle'] })
        Page.valid_handle?(@handle).should be(true)
      end
      
      it 'should return true if the handle recognization raises an error' do
        ActionController::Routing::Routes.stubs(:recognize_path).raises(ActionController::RoutingError.new('No route matches'))
        Page.valid_handle?(@handle).should be(true)
      end
      
      it 'should prepend a / to the given handle if needed' do
        handle = 'something'
        ActionController::Routing::Routes.expects(:recognize_path).with("/#{handle}").returns({})
        Page.valid_handle?(handle)
      end
      
      it 'should handle a nil handle' do
        ActionController::Routing::Routes.expects(:recognize_path).with('/').returns({})
        Page.valid_handle?(nil)
      end
    end
  end
  
  it 'should be able to check if its handle is valid' do
    @page.should respond_to(:valid_handle?)
  end
  
  describe 'checking if its handle is valid' do
    it 'should delegate to the class, passing its own handle' do
      @page.handle = 'handle'
      Page.expects(:valid_handle?).with(@page.handle)
      @page.valid_handle?
    end
    
    it 'should return the result from the class method' do
      result = 'some result'
      Page.stubs(:valid_handle?).returns(result)
      @page.valid_handle?.should == result
    end
  end
  
  it 'should have a path' do
    @page.should respond_to(:path)
  end
  
  describe 'path' do
    it 'should be the handle with a prepended /' do
      @page.stubs(:handle).returns('some_handle')
      @page.path.should == '/some_handle'
    end
  end
end
