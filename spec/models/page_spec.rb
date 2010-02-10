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

    it 'should have contents' do
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
  
  describe 'associations' do
    it 'can have a template' do
      Page.new.should respond_to(:template)
    end
    
    it 'allows setting and retrieving the template' do
      @page = Page.generate!
      @page.template = template = Template.generate!
      @page.save!
      Page.find(@page.id).template.should == template
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
  
    it 'should not include snippets when finding' do
      Page.delete_all
      Snippet.delete_all
      
      # OD doesn't look for exemplars in plugins
      Page.generate!(:handle => 'page')
      Snippet.generate!(:handle => 'snippet')
      
      Page.count.should == 1
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
  
  it 'should have full contents' do
    @page.should respond_to(:full_contents)
  end
  
  describe 'full contents' do
    it 'should accept a hash of replacements' do
      lambda { @page.full_contents({}) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a hash of replacements' do
      lambda { @page.full_contents }.should_not raise_error(ArgumentError)      
    end
    
    describe 'when no replacements are specified' do
      it 'should be the page contents in simple cases' do
        contents = 'abba dabba'
        @page.contents = contents
        @page.full_contents.should == contents
      end
    
      it 'should include the contents of any referenced snippet' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @page = Page.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @page.full_contents.should == "big bag boom #{snippet_contents} badaboom"
      end
    
      it 'should handle multiple snippet references' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
        @page = Page.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
        @page.full_contents.should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end
    
      it 'should replace an unknown snippet reference with the empty string' do
        @page = Page.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
        @page.full_contents.should == "big bag boom  badaboom"
      end
    end
    
    describe 'when replacements are specified' do
      before :each do
        @replacements = { 'replacement' => 'This is the replacement'}
      end
      
      it 'should be the page contents in simple cases and there are no replacement matches' do
        contents = 'abba dabba'
        @page.contents = contents
        @page.full_contents(@replacements).should == contents
      end
    
      it 'should include the contents of any referenced snippet if it does not match a replacement' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @page = Page.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @page.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"
      end
    
      it 'should handle multiple snippet references that do not match replacements' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
        @page = Page.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
        @page.full_contents(@replacements).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end
    
      it 'should replace a matched replacement with its replacement string' do
        contents = 'abba dabba {{ replacement }} yabba dabba'
        @page.contents = contents
        @page.full_contents(@replacements).should == "abba dabba This is the replacement yabba dabba"
      end
      
      it 'should prefer to use a snippet instead of a replacement when there is a conflict' do
        snippet_handle = 'replacement'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @page = Page.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @page.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"        
      end

      it 'should replace an unknown snippet reference with the empty string' do
        @page = Page.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
        @page.full_contents(@replacements).should == "big bag boom  badaboom"
      end      
    end
  end
end
