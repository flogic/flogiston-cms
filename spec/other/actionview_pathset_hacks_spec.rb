require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe ActionView::PathSet do
  describe 'finding a template' do
    before :each do
      @path = 'some/path'
      @format = 'fmt'
      @fallback = 'fallback'
      
      @pathset = ActionView::PathSet.new
    end
    
    describe 'when not given a Layout object' do
      it 'should use the old find-template logic with the given arguments' do
        @pathset.expects(:find_template_without_flogiston_layout).with(@path, @format, @fallback)
        @pathset.send(:find_template, @path, @format, @fallback)
      end
      
      it 'should return the result of the old find-template logic' do
        result = 'some result'
        @pathset.stubs(:find_template_without_flogiston_layout).returns(result)
        @pathset.send(:find_template, @path, @format, @fallback).should == result
      end
    end
    
    describe 'when given a Layout object' do
      before :each do
        @layout = Layout.new
      end
      
      it 'should not use the old find-template logic with the given arguments' do
        @pathset.expects(:find_template_without_flogiston_layout).never
        @pathset.send(:find_template, @layout)
      end
      
      it 'should return the Layout object' do
        @pathset.send(:find_template, @layout).should == @layout
      end
    end
  end
end
