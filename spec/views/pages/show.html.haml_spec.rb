require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'pages/show' do
  before :each do
    assigns[:page] = @page = Page.new(:title => 'test title', :contents => 'test contents')
  end
  
  def do_render
    render 'pages/show'
  end

  it 'should include the page title' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape@page.title))
  end
  
  it 'should include the page contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape@page.contents))
  end

end
