require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe PagesController do
  before :each do
  end

  describe 'show' do
    before :each do
      @page = Page.generate!
      @id = @page.id.to_s
      Page.stubs(:find).returns(@page)
    end
    
    def do_get
      get :show, :id => @id
    end

    it 'should look up the requested page' do
      Page.expects(:find).with(@id).returns(@page)
      do_get
    end

    it 'should make the requested page available to the view' do
      do_get
      assigns[:page].should == @page
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should render the show view' do
      do_get
      response.should render_template('show')
    end

    it 'should use the default layout' do
      do_get
      response.layout.should be_nil
    end
  end
end
