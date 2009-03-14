require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe Admin::PagesController do
  describe 'when integrating' do

    integrate_views

    before :all do
      Page.delete_all
    end

    describe 'show' do
      it 'should be successful' do
        @page = Page.generate!
        get :show, :id => @page.id
        response.should be_success
      end
    end

    describe 'new' do
      it 'should be successful' do
        get :new
        response.should be_success
      end
    end

    describe 'create' do
      it 'should redirect' do
        post :create, :page => Page.spawn.attributes
        response.should be_redirect
      end
    end
  end
end
