require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe PagesHelper do
  it 'should have a means of showing an invalid handle marker' do
    helper.should respond_to(:show_invalid_handle)
  end
  
  describe 'showing an invalid handle marker' do
    before :each do
      @page = Page.generate!
    end
    
    it 'should accept a page' do
      lambda { helper.show_invalid_handle(@page) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a page' do
      lambda { helper.show_invalid_handle }.should raise_error(ArgumentError)
    end
    
    it 'should check if the page has an valid handle' do
      @page.expects(:valid_handle?)
      helper.show_invalid_handle(@page)
    end
    
    it 'should return the empty string if the page handle is valid' do
      @page.stubs(:valid_handle?).returns(true)
      helper.show_invalid_handle(@page).should == ''
    end
    
    it 'should return a marker if the page handle is invalid' do
      @page.stubs(:valid_handle?).returns(false)
      helper.show_invalid_handle(@page).should == '<span class="error">!</span>'
    end
  end
end
