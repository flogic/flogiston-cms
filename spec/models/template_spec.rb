require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Template do
  before :each do
    @template = Template.new
  end

  describe 'attributes' do
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
    
    it 'should not check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Template.expects(:valid_handle?).never
      Template.generate(:handle => handle)
    end
  end
  
  describe 'associations' do
    it 'can have pages' do
      @template.should respond_to(:pages)
    end
    
    it 'should allow setting and retrieving pages' do
      template = Template.generate!
      template.pages << page = Page.generate!
      template.pages.should include(page)
    end
  end
  
  it 'should have full contents' do
    @template.should respond_to(:full_contents)
  end
  
  describe 'full contents' do
    it 'should accept a hash of replacements' do
      lambda { @template.full_contents({}) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a hash of replacements' do
      lambda { @template.full_contents }.should_not raise_error(ArgumentError)      
    end
    
    describe 'when no replacements are specified' do
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
    
    describe 'when replacements are specified' do
      before :each do
        @replacements = { 'replacement' => 'This is the replacement'}
      end
      
      it 'should be the template contents in simple cases and there are no replacement matches' do
        contents = 'abba dabba'
        @template.contents = contents
        @template.full_contents(@replacements).should == contents
      end
    
      it 'should include the contents of any referenced snippet if it does not match a replacement' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @template = Template.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @template.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"
      end
    
      it 'should handle multiple snippet references that do not match replacements' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
        @template = Template.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
        @template.full_contents(@replacements).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end
    
      it 'should replace a matched replacement with its replacement string' do
        contents = 'abba dabba {{ replacement }} yabba dabba'
        @template.contents = contents
        @template.full_contents(@replacements).should == "abba dabba This is the replacement yabba dabba"
      end
      
      it 'should match replacements with symbol keys' do
        replacements = { :replacement => 'This is the replacement' }
        
        contents = 'abba dabba {{ replacement }} yabba dabba'
        @template.contents = contents
        @template.full_contents(replacements).should == "abba dabba This is the replacement yabba dabba"
      end
      
      it 'should prefer to use a snippet instead of a replacement when there is a conflict' do
        snippet_handle = 'replacement'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @template = Template.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @template.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"        
      end

      it 'should replace an unknown snippet reference with the empty string' do
        @template = Template.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
        @template.full_contents(@replacements).should == "big bag boom  badaboom"
      end      
    end
  end
  
  describe 'to support pretending to be an ActionView Layout' do
    it 'should have a path without format and extension' do
      @template.should respond_to(:path_without_format_and_extension)
    end
    
    describe 'path_without_format_and_extension' do
      before :each do
        @template.handle = 'some_template'
      end
      
      it 'should indicate this is a Template object' do
        @template.path_without_format_and_extension.should include('Template')
      end
      
      it 'should include the handle' do
        @template.path_without_format_and_extension.should include(@template.handle)
      end
    end
    
    it 'should render_template' do
      @template.should respond_to(:render_template)
    end
    
    describe 'render_template' do
      before :each do
        @template.contents = 'contents go here, yes?'
        @template_full_contents = 'full contents'
        @template.stubs(:full_contents).returns(@template_full_contents)
        
        @template_obj = ActionView::Template.new('')
        @template_obj.stubs(:render_template)
        ActionView::Template.stubs(:new).returns(@template_obj)
        
        @view = 'some view'
        @locals = { :this => :that, :other => :thing }
      end
      
      it 'should accept a view and local assigns' do
        lambda { @template.render_template(@view, @locals) }.should_not raise_error(ArgumentError)
      end
      
      it 'should accept just a view' do
        lambda { @template.render_template(@view) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a view' do
        lambda { @template.render_template }.should raise_error(ArgumentError)
      end
      
      it 'should initialize an ActionView::Template object with an empty argument' do
        ActionView::Template.expects(:new).with('').returns(@template_obj)
        @template.render_template(@view, @locals)
      end
      
      it "should get the template full contents" do
        @template.expects(:full_contents).returns(@template_full_contents)
        @template.render_template(@view, @locals)
      end
      
      it "should set the ActionView::Template object's source to the template's full contents" do
        @template.render_template(@view, @locals)
        @template_obj.source.should == @template_full_contents
      end
      
      it "should set the ActionView::Template object to recompile" do
        @template.render_template(@view, @locals)
        @template_obj.recompile?.should be_true
      end
      
      it 'should make the ActionView::Template object render the template with the given view and local assigns' do
        @template_obj.expects(:render_template).with(@view, @locals)
        @template.render_template(@view, @locals)
      end
      
      it 'should return the result of the rendering' do
        @results = 'render results'
        @template_obj.stubs(:render_template).returns(@results)
        
        @template.render_template(@view, @locals).should == @results
      end
      
      it 'should default the local assigns to the empty hash' do
        @template_obj.expects(:render_template).with(@view, {})
        @template.render_template(@view)
      end
    end
    
    it 'should refresh itself' do
      @template.should respond_to(:refresh)
    end
    
    describe 'refreshing' do
      describe 'if the template is not a new record' do
        before :each do
          @template = Template.generate!
        end
        
        it 'should simply reload' do
          @template.expects(:reload)
          @template.refresh
        end
        
        it 'should return itself' do
          @template.refresh.should == @template
        end
      end
      
      describe 'if the template is a new record' do
        before :each do
          @template = Template.spawn
        end
        
        it 'should simply reload' do
          @template.expects(:reload).never
          @template.refresh
        end
        
        it 'should return itself' do
          @template.refresh.should == @template
        end
      end
      
      it 'should eventually be more efficient and check if a reload is necessary'
    end
  end
end
