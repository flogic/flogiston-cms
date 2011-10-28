require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Layout do
  before :each do
    @layout = Layout.spawn
  end

  describe 'attributes' do
    it 'should have a handle' do
      @layout.should respond_to(:handle)
    end
    
    it 'should allow setting and retrieving the handle' do
      @layout.handle = 'test_handle'
      @layout.save!
      @layout.reload.handle.should == 'test_handle'
    end
    
    it 'should have contents' do
      @layout.should respond_to(:contents)
    end

    it 'should allow setting and retrieving the contents' do
      @layout.contents = 'Test Contents'
      @layout.save!
      @layout.reload.contents.should == 'Test Contents'
    end

    it 'should have format' do
      @layout.should respond_to(:format)
    end

    it 'should allow setting and retrieving the format' do
      @layout.format = 'haml'
      @layout.save!
      @layout.reload.format.should == 'haml'
    end

    it 'should have a default flag' do
      @layout.should respond_to(:default)
    end

    it 'should allow setting and retrieving the default flag' do
      @layout.default = true
      @layout.save!
      @layout.reload.default.should == true
    end
  end

  describe 'validations' do
    it 'should require handles to be unique' do
      Layout.generate!(:handle => 'duplicate handle')
      dup = Layout.generate(:handle => 'duplicate handle')
      dup.errors.should be_invalid(:handle)
    end
    
    it 'should require handle' do
      layout = Layout.generate(:handle => nil)
      layout.errors.should be_invalid(:handle)
    end
    
    it 'should not check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Layout.expects(:valid_handle?).never
      Layout.generate(:handle => handle)
    end
  end
  
  it 'should have full contents' do
    @layout.should respond_to(:full_contents)
  end
  
  describe 'full contents' do
    it 'should accept a hash of replacements' do
      lambda { @layout.full_contents({}) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a hash of replacements' do
      lambda { @layout.full_contents }.should_not raise_error(ArgumentError)
    end
    
    describe 'when no replacements are specified' do
      it 'should be the layout contents in simple cases' do
        contents = 'abba dabba'
        @layout.contents = contents
        @layout.full_contents.should == contents
      end
    
      it 'should include the contents of any referenced snippet' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @layout = Layout.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @layout.full_contents.should == "big bag boom #{snippet_contents} badaboom"
      end
    
      it 'should handle multiple snippet references' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
        @layout = Layout.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
        @layout.full_contents.should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end
    
      it 'should replace an unknown snippet reference with the empty string' do
        @layout = Layout.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
        @layout.full_contents.should == "big bag boom  badaboom"
      end

      it 'should format included snippet contents' do
        snippet = Snippet.generate!(:handle => 'testsnip', :contents => 'blah *blah* blah', :format => 'markdown')
        @layout = Layout.generate!(:contents => contents = "big bag boom {{ #{snippet.handle} }} badaboom")
        @layout.full_contents.should == "big bag boom #{snippet.full_contents} badaboom"
      end

      it 'should correctly indent raw snippets used in HAML layouts' do
        contents = {}
        contents[:layout] = "
this
  is
    a
    {{ thing }}
  test
"
        contents[:snippet] = "
really
  crazy
  blah
boing
  boom
"
        contents[:expected] = "
this
  is
    a
    really
      crazy
      blah
    boing
      boom
  test
"
        contents.each { |k, v|  v.strip! }

        @layout = Layout.generate!(:format => 'haml', :contents => contents[:layout])
        @snippet = Snippet.generate!(:format => 'raw', :contents => contents[:snippet], :handle => 'thing')
        @layout.full_contents.should == contents[:expected]
      end

      it 'should not change snippet identation for non-HAML layouts' do
        contents = {}
        contents[:layout] = "
this
  is
    a
    {{ thing }}
  test
"
        contents[:snippet] = "
really
  crazy
  blah
boing
  boom
"
        contents[:expected] = "
this
  is
    a
    really
  crazy
  blah
boing
  boom
  test
"
        contents.each { |k, v|  v.strip! }

        @layout = Layout.generate!(:format => 'erb', :contents => contents[:layout])
        @snippet = Snippet.generate!(:format => 'raw', :contents => contents[:snippet], :handle => 'thing')
        @layout.full_contents.should == contents[:expected]
      end
    end
    
    describe 'when replacements are specified' do
      before :each do
        @replacements = { 'replacement' => 'This is the replacement'}
      end
      
      it 'should be the layout contents in simple cases and there are no replacement matches' do
        contents = 'abba dabba'
        @layout.contents = contents
        @layout.full_contents(@replacements).should == contents
      end
    
      it 'should include the contents of any referenced snippet if it does not match a replacement' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @layout = Layout.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @layout.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"
      end
    
      it 'should handle multiple snippet references that do not match replacements' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')
      
        @layout = Layout.generate!(:contents => "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom")
        @layout.full_contents(@replacements).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end
    
      it 'should replace a matched replacement with its replacement string' do
        contents = 'abba dabba {{ replacement }} yabba dabba'
        @layout.contents = contents
        @layout.full_contents(@replacements).should == "abba dabba This is the replacement yabba dabba"
      end
      
      it 'should match replacements with symbol keys' do
        replacements = { :replacement => 'This is the replacement' }
        
        contents = 'abba dabba {{ replacement }} yabba dabba'
        @layout.contents = contents
        @layout.full_contents(replacements).should == "abba dabba This is the replacement yabba dabba"
      end
      
      it 'should prefer to use a snippet instead of a replacement when there is a conflict' do
        snippet_handle = 'replacement'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)
      
        @layout = Layout.generate!(:contents => "big bag boom {{ #{snippet_handle} }} badaboom")
        @layout.full_contents(@replacements).should == "big bag boom #{snippet_contents} badaboom"        
      end

      it 'should replace an unknown snippet reference with the empty string' do
        @layout = Layout.generate!(:contents => "big bag boom {{ who_knows }} badaboom")
        @layout.full_contents(@replacements).should == "big bag boom  badaboom"
      end      
    end
  end
  
  describe 'to support pretending to be an ActionView Template' do
    it 'should have a path without format and extension' do
      @layout.should respond_to(:path_without_format_and_extension)
    end
    
    describe 'path_without_format_and_extension' do
      before :each do
        @layout.handle = 'some_template'
      end
      
      it 'should indicate this is a Layout object' do
        @layout.path_without_format_and_extension.should include('Layout')
      end
      
      it 'should include the handle' do
        @layout.path_without_format_and_extension.should include(@layout.handle)
      end
    end
    
    it 'should render_template' do
      @layout.should respond_to(:render_template)
    end
    
    describe 'render_template' do
      before :each do
        @layout.contents = 'contents go here, yes?'
        @layout_full_contents = 'full contents'
        @layout.stubs(:full_contents).returns(@layout_full_contents)
        
        @layout_obj = ActionView::Template.new('')
        @layout_obj.stubs(:render_template)
        ActionView::Template.stubs(:new).returns(@layout_obj)
        
        @view = 'some view'
        @locals = { :this => :that, :other => :thing }
      end
      
      it 'should accept a view and local assigns' do
        lambda { @layout.render_template(@view, @locals) }.should_not raise_error(ArgumentError)
      end
      
      it 'should accept just a view' do
        lambda { @layout.render_template(@view) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a view' do
        lambda { @layout.render_template }.should raise_error(ArgumentError)
      end
      
      it 'should initialize an ActionView::Template object with an empty argument' do
        ActionView::Template.expects(:new).with('').returns(@layout_obj)
        @layout.render_template(@view, @locals)
      end
      
      it "should get the layout full contents" do
        @layout.expects(:full_contents).returns(@layout_full_contents)
        @layout.render_template(@view, @locals)
      end
      
      it "should set the ActionView::Template object's source to the layout's full contents" do
        @layout.render_template(@view, @locals)
        @layout_obj.source.should == @layout_full_contents
      end
      
      it "should set the ActionView::Template object to recompile" do
        @layout.render_template(@view, @locals)
        @layout_obj.recompile?.should be_true
      end

      it "should set the ActionView::Template object's extension to the layout's format" do
        format = 'haml'
        @layout.format = format
        @layout.render_template(@view, @locals)
        @layout_obj.extension.should == format
      end

      it "should set the ActionView::Template object's extension to nil if the layout has no set format" do
        format = nil
        @layout.format = format
        @layout.render_template(@view, @locals)
        @layout_obj.extension.should == format
      end
      
      it 'should make the ActionView::Template object render the template with the given view and local assigns' do
        @layout_obj.expects(:render_template).with(@view, @locals)
        @layout.render_template(@view, @locals)
      end
      
      it 'should return the result of the rendering' do
        @results = 'render results'
        @layout_obj.stubs(:render_template).returns(@results)
        
        @layout.render_template(@view, @locals).should == @results
      end
      
      it 'should default the local assigns to the empty hash' do
        @layout_obj.expects(:render_template).with(@view, {})
        @layout.render_template(@view)
      end
    end
    
    it 'should refresh itself' do
      @layout.should respond_to(:refresh)
    end
    
    describe 'refreshing' do
      describe 'if the layout is not a new record' do
        before :each do
          @layout = Layout.generate!
        end
        
        it 'should simply reload' do
          @layout.expects(:reload)
          @layout.refresh
        end
        
        it 'should return itself' do
          @layout.refresh.should == @layout
        end
      end
      
      describe 'if the layout is a new record' do
        before :each do
          @layout = Layout.spawn
        end
        
        it 'should simply reload' do
          @layout.expects(:reload).never
          @layout.refresh
        end
        
        it 'should return itself' do
          @layout.refresh.should == @layout
        end
      end
      
      it 'should eventually be more efficient and check if a reload is necessary'
    end
  end
  
  describe 'to support pretending to be an ActionView Template (view)' do
    it "should indicate whether it's exempt from layout" do
      @layout.should respond_to(:exempt_from_layout?)
    end
    
    describe "indicating whether it's exempt from layout" do
      it 'should return false' do
        @layout.exempt_from_layout?.should == false
      end
    end
  end

  it 'should be able to retrieve the default' do
    Layout.should respond_to(:default)
  end

  describe 'retrieving the default' do
    before do
      Layout.delete_all
      @layouts = Array.new(5) { Layout.generate!(:default => false) }
      @default = @layouts[3]
      @default.update_attributes!(:default => true)
    end

    it 'should return the Layout object marked as default' do
      Layout.default.should == @default
    end

    it 'should return one of the Layout objects marked as default if there are multiple matches' do
      defaults = @layouts.values_at(0,2,3)
      defaults.each { |l|  l.update_attributes!(:default => true) }

      result = Layout.default
      defaults.should include(result)
    end

    it 'should return nil if no Layout objects are marked as default' do
      Layout.update_all(:default => false)
      Layout.default.should be_nil
    end

    it 'should return nil if there are no Layout objects' do
      Layout.delete_all
      Layout.default.should be_nil
    end
  end
end
