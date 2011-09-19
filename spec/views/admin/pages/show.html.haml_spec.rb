require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/show' do
  before :each do
    assigns[:page] = @page = Page.generate!(:title => 'test title', :format => 'markdown', :contents => 'test contents')
  end

  def do_render
    render 'admin/pages/show'
  end

  it 'should include the page title' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@page.title)))
  end

  it 'should include the page handle' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@page.handle)))
  end

  it 'should include the page contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@page.contents)))
  end

  it 'should format the page contents with markdown' do
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

  it 'should allow unformatted snippet contents within formatted page contents' do
    @page.format = 'markdown'
    Snippet.generate!(:handle => 'testsnip', :format => 'raw', :contents => "
 1. something
 1. nothing
    ")
    @page.contents += "\n{{ testsnip }}\n"

    do_render
    response.should have_text(/1\. nothing/)
  end

  it 'should include an edit link' do
    do_render
    response.should have_tag('a[href=?]', edit_admin_page_path(@page))
  end
end
