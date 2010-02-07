require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe 'pages/_show' do
  before :each do
    @page = Page.new(:title => 'test title', :contents => 'test contents')
  end
  
  def do_render
    render :partial => 'pages/show', :locals => { :page => @page }
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
  
  it 'should include referenced snippets' do
    Snippet.generate!(:handle => 'testsnip', :contents => "
 1. something
 1. nothing
    ")
    @page.contents += "\n{{ testsnip }}\n"
 
    do_render
    response.should have_tag('li', :text => /something/)
  end
end
