require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe PagesController do
  describe 'when integrating' do
    
    integrate_views

    before :all do
      Page.delete_all
    end

    describe 'show' do
      describe 'when given a valid id' do
        it 'should be successful' do
          page = Page.generate!
          get :show, :id => page.id.to_s
          response.should be_success
        end
      end

      describe 'when given a valid handle' do 
        it 'should be successful' do
          Page.generate!(:handle => 'test_handle')
          get :show, :path => ['test_handle']
          response.should be_success
        end
      end

      describe 'when given a valid empty handle' do
        it 'should be successful' do
          Page.generate!(:handle => '')
          get :show, :path => []
          response.should be_success
        end
      end
    end
  end
end
