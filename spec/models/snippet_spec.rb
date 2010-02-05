require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Snippet do
  before :each do
    @snippet = Snippet.new
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
    
    it 'should not check if the handle is valid according to the class' do
      handle = '/some_crazy_handle'
      Snippet.expects(:valid_handle?).never
      Snippet.generate(:handle => handle)
    end
  end
end
