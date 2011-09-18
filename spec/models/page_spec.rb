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

    it 'should have format' do
      @page.should respond_to(:format)
    end

    it 'should allow setting and retrieving the format' do
      @page.format = 'markdown'
      @page.save!
      @page.reload.format.should == 'markdown'
    end

    it 'should have contents' do
      @page.should respond_to(:contents)
    end

    it 'should allow setting and retrieving the contents' do
      @page.contents = 'Test Contents'
      @page.save!
      @page.reload.contents.should == 'Test Contents'
    end

    it 'should have values' do
      @page.should respond_to(:values)
    end

    it 'should allow setting and retrieving the values as a hash' do
      data = { 'title' => 'test title', 'color' => 'blue' }
      @page.values = data
      @page.save!
      @page.reload.values.should == data
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

  describe 'delegation' do
    it 'should have template replacements' do
      Page.new.should respond_to(:template_replacements)
    end

    describe 'template replacements' do
      before do
        @page = Page.generate!(:template => Template.generate!)
      end

      it 'should forward the call to the page template' do
        @page.template.expects(:replacements)
        @page.template_replacements
      end

      it 'should return the value from the template' do
        value = 'smee'
        @page.template.stubs(:replacements).returns(value)
        @page.template_replacements.should == value
      end

      it 'should return the empty list if the page has no template' do
        @page.update_attributes!(:template => nil)
        @page.template_replacements.should == []
      end
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
    describe 'when the page has a template' do
      before :each do
        @template = Template.generate!
        @page = Page.generate!(:template => @template)
        @contents = "formatted page contents"
        @page.stubs(:formatted).returns(@contents)
      end

      it "should get the template full contents with the page full contents specifed as the 'contents' replacement" do
        @template.expects(:full_contents).with({ 'contents' => @contents })
        @page.full_contents
      end

      it 'should return the full contents from the template' do
        template_contents = 'template full contents go here'
        @template.stubs(:full_contents).returns(template_contents)
        @page.full_contents.should == template_contents
      end

      describe 'when the page holds values' do
        before do
          @values = { 'title' => 'test title', 'color' => 'blue'}
          @page.values = @values
        end

        it 'should pass the values along with the page full contents to the template' do
          expected = { 'title' => 'test title', 'color' => 'blue', 'contents' => @contents }
          @template.expects(:full_contents).with(expected)
          @page.full_contents
        end

        it "should ignore any value that happens to be called 'contents'" do
          @page.values['contents'] = 'something else, why not?'
          expected = { 'title' => 'test title', 'color' => 'blue', 'contents' => @contents }
          @template.expects(:full_contents).with(expected)
          @page.full_contents
        end
      end

      describe 'when the page explicitly holds no values' do
        before do
          @page.values = nil
        end

        it 'should pass the page full contents to the template' do
          @template.expects(:full_contents).with({ 'contents' => @contents })
          @page.full_contents
        end
      end
    end

    describe 'when the page has no template' do
      before do
        @page.update_attributes!(:template => nil)
      end

      it 'should format page contents' do
        @page.contents = 'some contents'
        @page.expects(:formatted).returns(@contents)
        @page.full_contents
      end

      it 'should return the results of formatting page contents' do
        @contents = 'formatted page contents'
        @page.stubs(:formatted).returns(@contents)
        @page.full_contents.should == @contents
      end
    end
  end

  it 'should provide formatted contents' do
    @page.should respond_to(:formatted)
  end

  describe 'providing formatted contents' do
    before do
      @contents = 'expanded page contents'
      Page.stubs(:expand).returns(@contents)

      @formatted = 'formatted page contents'
      @formatter = Object.new
      @formatter.stubs(:process).returns(@formatted)

      @page.stubs(:formatter).returns(@formatter)
    end

    it 'should expand the page contents' do
      @page.contents = 'some contents'
      Page.expects(:expand).with({}, @page.contents).returns(@contents)
      @page.formatted
    end

    it 'should pass no replacements to expansion even if the page holds values' do
      @page.values = { 'title' => 'test title', 'color' => 'blue' }
      @page.contents = 'some contents'
      Page.expects(:expand).with({}, @page.contents).returns(@contents)
      @page.formatted
    end

    it 'should get the page formatter' do
      @page.expects(:formatter).returns(@formatter)
      @page.formatted
    end

    it 'should pass the expanded page contents to the formatter for formatting' do
      @formatter.expects(:process).with(@contents)
      @page.formatted
    end

    it 'should return the results of formatting the expanded page contents' do
      @formatter.stubs(:process).returns(@formatted)
      @page.formatted.should == @formatted
    end
  end

  it 'should provide a formatter' do
    @page.should respond_to(:formatter)
  end

  describe 'providing a formatter' do
    describe "when the format is 'markdown'" do
      before do
        @page.format = 'markdown'
      end

      it 'should return an object that will format the input via markdown when processing' do
        @contents = "
 * whatever
 * whatever else
"
        result = @page.formatter.process(@contents)
        result.should match(Regexp.new(Regexp.escape('<li>whatever</li>')))
      end
    end

    describe "when the format is 'raw'" do
      before do
        @page.format = 'raw'
      end

      it 'should return an object that will return the input verbatim when processing' do
        @contents = "
 * whatever
 * whatever else
"
        @page.formatter.process(@contents).should == @contents
      end
    end

    describe 'when the format is not set' do
      before do
        @page.format = nil
      end

      it 'should format as markdown' do
        @contents = "
 * whatever
 * whatever else
"
        result = @page.formatter.process(@contents)
        result.should match(Regexp.new(Regexp.escape('<li>whatever</li>')))
      end
    end
  end

  describe 'expanding contents' do
    it 'should be the contents in simple cases' do
      contents = 'abba dabba'
      Page.expand({}, contents) == contents
    end

    it 'should include the contents of any referenced snippet' do
      snippet_handle = 'testsnip'
      snippet_contents = 'blah blah blah'
      Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)

      contents = "big bag boom {{ #{snippet_handle} }} badaboom"
      Page.expand({}, contents).should == "big bag boom #{snippet_contents} badaboom"
    end

    it 'should handle multiple snippet references' do
      snippets = []
      snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
      snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')

      contents = "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom"
      Page.expand({}, contents).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
    end

    it 'should replace an unknown snippet reference with the empty string' do
      contents = "big bag boom {{ who_knows }} badaboom"
      Page.expand({}, contents).should == "big bag boom  badaboom"
    end

    it 'should format included snippet contents' do
      snippet = Snippet.generate!(:handle => 'testsnip', :contents => 'blah *blah* blah', :format => 'markdown')
      contents = "big bag boom {{ #{snippet.handle} }} badaboom"
      Page.expand({}, contents).should == "big bag boom #{snippet.full_contents} badaboom"
    end
  end
end
