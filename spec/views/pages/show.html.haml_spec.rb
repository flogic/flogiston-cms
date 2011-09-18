require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe 'pages/show' do
  before :each do
    assigns[:page] = @page = Page.new(:title => 'test title', :format => 'markdown', :contents => 'test contents')
  end
  
  def do_render
    render 'pages/show'
  end

  it 'should include the page contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@page.contents)))
  end

  it 'should format the page contents according to the page format' do
    @page.format = 'markdown'
    @page.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('li', :text => /whatever/)
  end

  it 'should leave page contents unformatted if page format indicates it' do
    @page.format = 'raw'
    @page.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_text(/\* whatever/)
  end
  
  it 'should include referenced snippets' do
    Snippet.generate!(:handle => 'testsnip', :format => 'markdown', :contents => "
 1. something
 1. nothing
    ")
    @page.contents += "\n{{ testsnip }}\n"
 
    do_render
    response.should have_tag('li', :text => /something/)
  end
end
