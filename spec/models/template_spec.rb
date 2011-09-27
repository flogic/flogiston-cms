require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Template do
  before :each do
    @template = Template.spawn
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
    
    it 'should require handle' do
      template = Template.generate(:handle => nil)
      template.errors.should be_invalid(:handle)
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
    before do
      @formatted = 'formatted template content'
      @template.stubs(:formatted).returns(@formatted)
    end

    it 'should accept a hash of replacements' do
      lambda { @template.full_contents(:a => 'b') }.should_not raise_error(ArgumentError)
    end

    it 'should not require a hash of replacements' do
      lambda { @template.full_contents }.should_not raise_error(ArgumentError)
    end

    it 'should get the formatted contents, passing the given replacements' do
      replacements = { 'thing' => 'other' }
      @template.expects(:formatted).with(replacements)
      @template.full_contents(replacements)
    end

    it 'should default the replacements to the empty hash' do
      @template.expects(:formatted).with({})
      @template.full_contents
    end

    it 'should return the formatted contents' do
      @template.stubs(:formatted).returns(@formatted)
      @template.full_contents.should == @formatted
    end
  end

  it 'should provide formatted contents' do
    @template.should respond_to(:formatted)
  end

  describe 'providing formatted contents' do
    describe 'when the template has content' do
      before do
        @template.contents = 'testing'

        @formatted = 'formatted template contents'
        @formatter = Object.new
        @formatter.stubs(:process).returns(@formatted)

        @template.stubs(:formatter).returns(@formatter)

        @expanded = 'expanded template contents'
        Template.stubs(:expand).returns(@expanded)
      end

      it 'should accept a hash of replacements' do
        lambda { @template.formatted(:a => 'b') }.should_not raise_error(ArgumentError)
      end

      it 'should not require a hash of replacements' do
        lambda { @template.formatted }.should_not raise_error(ArgumentError)
      end

      it 'should get the template formatter' do
        @template.expects(:formatter).returns(@formatter)
        @template.formatted
      end

      it 'should pass the template contents to the formatter for formatting' do
        @template.contents = 'some contents'
        @formatter.expects(:process).with(@template.contents).returns(@formatted)
        @template.formatted
      end

      it 'should expand the formatted template contents' do
        Template.expects(:expand).with({}, @formatted).returns(@expanded)
        @template.formatted
      end

      it 'should pass the given replacements to expansion' do
        replacements = { 'title' => 'test title', 'color' => 'blue' }
        Template.expects(:expand).with(replacements, @formatted).returns(@expanded)
        @template.formatted(replacements)
      end

      it 'should default replacements to the empty hash' do
        Template.expects(:expand).with({}, @formatted).returns(@expanded)
        @template.formatted
      end

      it 'should return the results of expanding the formatted template contents' do
        Template.stubs(:expand).returns(@expanded)
        @template.formatted.should == @expanded
      end
    end

    describe 'when the template has no content' do
      before do
        @template.contents = nil
      end

      it 'should be the empty string' do
        @template.formatted.should == ''
      end
    end
  end

  it 'should provide a formatter' do
    @template.should respond_to(:formatter)
  end

  describe 'providing a formatter' do
    describe "when the format is 'haml'" do
      before do
        @template.format = 'haml'
      end

      it 'should return an object that will format the input via haml when processing' do
        @contents = "
#hey
  .yo
"
        result = @template.formatter.process(@contents)
        result.should match(/<div class='yo'>\s*<\/div>/)
      end
    end

    describe "when the format is 'raw'" do
      before do
        @template.format = 'raw'
      end

      it 'should return an object that will return the input verbatim when processing' do
        @contents = "<%= @whatever -%>"
        @template.formatter.process(@contents).should == @contents
      end
    end

    describe 'when the format is not set' do
      before do
        @template.format = nil
      end

      it 'should format as raw' do
        @contents = "<%= @whatever -%>"
        @template.formatter.process(@contents).should == @contents
      end
    end
  end

  describe 'expanding contents' do
    describe 'when no replacements are specified' do
      it 'should be the contents in simple cases' do
        contents = 'abba dabba'
        Template.expand({}, contents) == contents
      end

      it 'should include the contents of any referenced snippet' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)

        contents = "big bag boom {{ #{snippet_handle} }} badaboom"
        Template.expand({}, contents).should == "big bag boom #{snippet_contents} badaboom"
      end

      it 'should handle multiple snippet references' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')

        contents = "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom"
        Template.expand({}, contents).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end

      it 'should replace an unknown snippet reference with the empty string' do
        contents = "big bag boom {{ who_knows }} badaboom"
        Template.expand({}, contents).should == "big bag boom  badaboom"
      end

      it 'should format included snippet contents' do
        snippet = Snippet.generate!(:handle => 'testsnip', :contents => 'blah *blah* blah', :format => 'markdown')
        contents = "big bag boom {{ #{snippet.handle} }} badaboom"
        Template.expand({}, contents).should == "big bag boom #{snippet.full_contents} badaboom"
      end
    end

    describe 'when replacements are specified' do
      before :each do
        @replacements = { 'replacement' => 'This is the replacement'}
      end

      it 'should include the contents of any referenced snippet if it does not match a replacement' do
        snippet_handle = 'testsnip'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)

        contents = "big bag boom {{ #{snippet_handle} }} badaboom"
        Template.expand(@replacements, contents).should == "big bag boom #{snippet_contents} badaboom"
      end

      it 'should handle multiple snippet references that do not match replacements' do
        snippets = []
        snippets.push Snippet.generate!(:handle => 'testsnip1', :contents => 'blah blah blah')
        snippets.push Snippet.generate!(:handle => 'testsnip2', :contents => 'bing bang bong')

        contents = "big bag {{#{snippets[0].handle}}} boom {{ #{snippets[1].handle} }} badaboom"
        Template.expand(@replacements, contents).should == "big bag #{snippets[0].contents} boom #{snippets[1].contents} badaboom"
      end

      it 'should replace a matched replacement with its replacement string' do
        contents = 'abba dabba {{ replacement }} yabba dabba'
        Template.expand(@replacements, contents) .should == "abba dabba This is the replacement yabba dabba"
      end

      it 'should match replacements with symbol keys' do
        replacements = { :replacement => 'This is the replacement' }

        contents = 'abba dabba {{ replacement }} yabba dabba'
        Template.expand(replacements, contents).should == "abba dabba This is the replacement yabba dabba"
      end

      it 'should prefer to use a snippet instead of a replacement when there is a conflict' do
        snippet_handle = 'replacement'
        snippet_contents = 'blah blah blah'
        Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)

        contents = "big bag boom {{ #{snippet_handle} }} badaboom"
        Template.expand(@replacements, contents).should == "big bag boom #{snippet_contents} badaboom"        
      end

      it 'should replace an unknown snippet reference with the empty string' do
        contents = "big bag boom {{ who_knows }} badaboom"
        Template.expand(@replacements, contents).should == "big bag boom  badaboom"
      end
    end
  end

  it 'should provide a list of replacements' do
    @template.should respond_to(:replacements)
  end

  describe 'providing a list of replacements' do
    it 'should be the empty list if the template has no placeholders' do
      @template = Template.generate!(:contents => 'simple stuff')
      @template.replacements.should == []
    end

    it "should be the empty list if the only placeholder is 'contents'" do
      @template = Template.generate!(:contents => 'simple {{ contents }} wrapper')
      @template.replacements.should == []
    end

    it "should return a list of all the placeholders except 'contents'" do
      @template = Template.generate!(:contents => 'a little {{ more }} complicated {{ contents }} wrapper with {{ things }} here')
      @template.replacements.should == %w[more things]
    end

    it 'should only return unique placeholders' do
      contents = "a little {{ more }} complicated
        {{ contents }} wrapper with
        {{ things }} here and then {{ other }} things
        and then the original {{ things }} repeated
      "
      @template = Template.generate!(:contents => contents)
      @template.replacements.should == %w[more things other]
    end

    it 'should be the empty list if the template has no content' do
      @template = Template.generate!(:contents => nil)
      @template.replacements.should == []
    end
  end
end
