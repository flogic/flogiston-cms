require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe 'pages/show' do
  before :each do
    assigns[:page] = @page = Page.new(:title => 'test title', :contents => 'test contents')
  end
  
  def do_render
    render 'pages/show'
  end

  it 'should include the page contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@page.contents)))
  end

  it 'should format the page contents with markdown' do
    @page.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('li', :text => /whatever/)
  end
end
