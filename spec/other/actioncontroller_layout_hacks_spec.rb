require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe ActionController::Layout do
  describe 'finding a template' do
    before :each do
      @layout = 'some_layout'
      @format = 'fmt'
      @fallback = 'fallback'
      
      @layout_class = Class.new { include ActionController::Layout }
      @layout_obj   = @layout_class.new
    end
    
    describe 'when not given a Layout object' do
      it 'should use the old find-layout logic with the given arguments' do
        @layout_obj.expects(:find_layout_without_flogiston_layout).with(@path, @format, @fallback)
        @layout_obj.send(:find_layout, @path, @format, @fallback)
      end
      
      it 'should return the result of the old find-layout logic' do
        result = 'some result'
        @layout_obj.stubs(:find_layout_without_flogiston_layout).returns(result)
        @layout_obj.send(:find_layout, @path, @format, @fallback).should == result
      end
    end
    
    describe 'when given a Layout object' do
      before :each do
        @layout = Layout.new
      end
      
      it 'should not use the old find-layout logic with the given arguments' do
        @layout_obj.expects(:find_layout_without_flogiston_layout).never
        @layout_obj.send(:find_layout, @layout)
      end
      
      it 'should refresh the Layout object' do
        @layout.expects(:refresh)
        @layout_obj.send(:find_layout, @layout)
      end
      
      it 'should return the Layout object' do
        @layout_obj.send(:find_layout, @layout).should == @layout
      end
    end
  end
end
