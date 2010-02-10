require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Template do
  before :each do
    @template = Template.new
  end

  describe 'attributes' do
    it 'should have a title' do
      @template.should respond_to(:title)
    end

    it 'should allow setting and retrieving the title' do
      @template.title = 'Test Title'
      @template.save!
      @template.reload.title.should == 'Test Title'
    end

    it 'should have a handle' do
      @template.should respond_to(:handle)
    end

    it 'should allow setting and retrieving the handle' do
      @template.handle = 'test_handle'
      @template.save!
      @template.reload.handle.should == 'test_handle'
    end

    it 'should have contents' do
      @template.should respond_to(:contents)
    end

    it 'should allow setting and retrieving the contents' do
      @template.contents = 'Test Contents'
      @template.save!
      @template.reload.contents.should == 'Test Contents'
    end
  end

  describe 'validations' do
    it 'should require handles to be unique' do
      Template.generate!(:handle => 'duplicate handle')
      dup = Template.generate(:handle => 'duplicate handle')
      dup.errors.should be_invalid(:handle)
    end
    
    it 'should check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Template.expects(:valid_handle?).with(handle).returns(true)
      Template.generate(:handle => handle)
    end
    
    it 'should require the handle to be valid according to the class' do
      Template.stubs(:valid_handle?).returns(false)
      template = Template.generate(:handle => 'some_handle')
      template.errors.should be_invalid(:handle)
    end
    
    it 'should accept handles that are valid according to the class' do
      Template.stubs(:valid_handle?).returns(true)
      template = Template.generate(:handle => 'some_handle')
      template.errors.should_not be_invalid(:handle)
    end
  end
  
  describe 'associations' do
    it 'can have pages' do
      Template.new.should respond_to(:pages)
    end
    
    it 'should allow setting and retrieving pages' do
      template = Template.generate!
      template.pages << page = Page.generate!
      template.pages.should include(page)
    end
  end
  
  describe 'as a class' do
    it 'should be able to check if a given handle is valid' do
      Template.should respond_to(:valid_handle?)
    end
    
    describe 'checking if a given handle is valid' do
      before :each do
        @handle = '/some_handle'
        ActionController::Routing::Routes.stubs(:recognize_path).returns({})
      end
      
      it 'should accept a handle' do
        lambda { Template.valid_handle?(@handle) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a handle' do
        lambda { Template.valid_handle? }.should raise_error(ArgumentError)
      end
      
      it 'should ask the routes to recognize the handle' do
        ActionController::Routing::Routes.expects(:recognize_path).with(@handle).returns({})
        Template.valid_handle?(@handle)
      end
      
      it 'should return false if the handle recognization is for an existent controller and action' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'something', :action => 'index' })
        Template.valid_handle?(@handle).should be(false)
      end
      
      it 'should return false if the handle recognization is for the pages controller and has no path' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'pages', :action => 'show', :id => '1' })
        Template.valid_handle?(@handle).should be(false)
      end
      
      it 'should return false if the handle recognization is for the pages controller and has a path' do
        ActionController::Routing::Routes.stubs(:recognize_path).returns({ :controller => 'pages', :action => 'show', :path => ['some_handle'] })
        Template.valid_handle?(@handle).should be(true)
      end
      
      it 'should return true if the handle recognization raises an error' do
        ActionController::Routing::Routes.stubs(:recognize_path).raises(ActionController::RoutingError.new('No route matches'))
        Template.valid_handle?(@handle).should be(true)
      end
      
      it 'should prepend a / to the given handle if needed' do
        handle = 'something'
        ActionController::Routing::Routes.expects(:recognize_path).with("/#{handle}").returns({})
        Template.valid_handle?(handle)
      end
      
      it 'should handle a nil handle' do
        ActionController::Routing::Routes.expects(:recognize_path).with('/').returns({})
        Template.valid_handle?(nil)
      end
    end
  
    it 'should not include snippets when finding' do
      Template.delete_all
      Snippet.delete_all
      
      # OD doesn't look for exemplars in plugins
      Template.generate!(:handle => 'template')
      Snippet.generate!(:handle => 'snippet')
      
      Template.count.should == 1
    end
  end
  
  it 'should be able to check if its handle is valid' do
    @template.should respond_to(:valid_handle?)
  end
  
  describe 'checking if its handle is valid' do
    it 'should delegate to the class, passing its own handle' do
      @template.handle = 'handle'
      Template.expects(:valid_handle?).with(@template.handle)
      @template.valid_handle?
    end
    
    it 'should return the result from the class method' do
      result = 'some result'
      Template.stubs(:valid_handle?).returns(result)
      @template.valid_handle?.should == result
    end
  end
  
  it 'should have a path' do
    @template.should respond_to(:path)
  end
  
  describe 'path' do
    it 'should be the handle with a prepended /' do
      @template.stubs(:handle).returns('some_handle')
      @template.path.should == '/some_handle'
    end
  end
  
  it 'should have full contents' do
    @template.should respond_to(:full_contents)
  end
  
  describe 'full contents' do
    it 'should be the template contents in simple cases' do
      contents = 'abba dabba'
      @template.contents = contents
      @template.full_contents.should == contents
    end
    
    it 'should include the contents of any referenced snippet' do
      snippet_handle = 'testsnip'
      snippet_contents = 'blah blah blah'
      Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
      @template = Template.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
      @template.full_contents.should == "big bag boom #{snippet_contents} badaboom"
    end
    
    it 'should handle multiple snippet references' do
      snippets = []
      snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
      snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
      @template = Template.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
      @template.full_contents.should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
    end
    
    it 'should replace an unknown snippet reference with the empty string' do
      @template = Template.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
      @template.full_contents.should == "big bag boom  badaboom"
    end
  end
end
