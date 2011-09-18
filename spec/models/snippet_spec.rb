require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Snippet do
  before :each do
    @snippet = Snippet.spawn
  end

  describe 'attributes' do
    it 'should have a handle' do
      @snippet.should respond_to(:handle)
    end

    it 'should allow setting and retrieving the handle' do
      @snippet.handle = 'test_handle'
      @snippet.save!
      @snippet.reload.handle.should == 'test_handle'
    end

    it 'should have contents' do
      @snippet.should respond_to(:contents)
    end

    it 'should allow setting and retrieving the contents' do
      @snippet.contents = 'Test Contents'
      @snippet.save!
      @snippet.reload.contents.should == 'Test Contents'
    end
  end

  describe 'validations' do
    it 'should require handles to be unique' do
      Snippet.generate!(:handle => 'duplicate handle')
      dup = Snippet.generate(:handle => 'duplicate handle')
      dup.errors.should be_invalid(:handle)
    end
    
    it 'should require handle' do
      snippet = Snippet.generate(:handle => nil)
      snippet.errors.should be_invalid(:handle)
    end
    
    it 'should not check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Snippet.expects(:valid_handle?).never
      Snippet.generate(:handle => handle)
    end
  end

  it 'should have full contents' do
    @snippet.should respond_to(:full_contents)
  end
  
  describe 'full contents' do
    before do
      @formatted = 'formatted snippet contents'
      @snippet.stubs(:formatted).returns(@formatted)
    end

    it 'should format the snippet contents' do
      @snippet.expects(:formatted)
      @snippet.full_contents
    end
    
    it 'should return the formatted contents' do
      @snippet.stubs(:formatted).returns(@formatted)
      @snippet.full_contents.should == @formatted
    end

  end

  it 'should provide formatted contents' do
    @snippet.should respond_to(:formatted)
  end

  describe 'providing formatted contents' do
    before do
      @contents = 'snippet contents'
      @snippet.contents = @contents

      @formatted = 'formatted snippet contents'
      @formatter = Object.new
      @formatter.stubs(:process).returns(@formatted)

      @snippet.stubs(:formatter).returns(@formatter)
    end

    it 'should get the snippet formatter' do
      @snippet.expects(:formatter).returns(@formatter)
      @snippet.formatted
    end

    it 'should pass the snippet contents to the formatter for formatting' do
      @formatter.expects(:process).with(@contents)
      @snippet.formatted
    end

    it 'should return the results of formatting the snippet contents' do
      @formatter.stubs(:process).returns(@formatted)
      @snippet.formatted.should == @formatted
    end

    it 'should not process any referenced snippet' do
      snippet_handle = 'testsnip'
      snippet_contents = 'blah blah blah'
      Snippet.generate!(:handle => snippet_handle, :contents => snippet_contents)

      @snippet.contents = "big bag boom {{ #{snippet_handle} }} badaboom"
      @formatter.expects(:process).with(@snippet.contents)
      @snippet.formatted
    end
  end

  it 'should provide a formatter' do
    @snippet.should respond_to(:formatter)
  end

  describe 'providing a formatter' do
    describe "when the format is 'markdown'" do
      before do
        @snippet.format = 'markdown'
      end

      it 'should return an object that will format the input via markdown when processing' do
        @contents = "
 * whatever
 * whatever else
"
        result = @snippet.formatter.process(@contents)
        result.should match(Regexp.new(Regexp.escape('<li>whatever</li>')))
      end
    end

    describe "when the format is 'raw'" do
      before do
        @snippet.format = 'raw'
      end

      it 'should return an object that will return the input verbatim when processing' do
        @contents = "
 * whatever
 * whatever else
"
        @snippet.formatter.process(@contents).should == @contents
      end
    end

    describe 'when the format is not set' do
      before do
        @snippet.format = nil
      end

      it 'should format as raw' do
        @contents = "
 * whatever
 * whatever else
"
        @snippet.formatter.process(@contents).should == @contents
      end
    end
  end

end
