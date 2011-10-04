require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))
include PagesHelper

describe 'admin/snippets/show' do
  before :each do
    assigns[:snippet] = @snippet = Snippet.generate!(:handle => 'test handle', :contents => 'test contents')
  end

  def do_render
    render 'admin/snippets/show'
  end

  it 'should include the snippet handle' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@snippet.handle)))
  end

  it 'should include the snippet contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@snippet.contents)))
  end

  it 'should format the snippet contents according to snippet format' do
    @snippet.format = 'markdown'
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('li', :text => /whatever/)
  end

  it 'should leave snippet contents unformatted if snippet format indicates it' do
    @snippet.format = 'raw'
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_text(/\* whatever/)
  end

  it 'should contain unformatted snippet contents in a pre block' do
    @snippet.format = 'raw'
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('pre', /\* whatever/)
  end

  it 'should contain unformatted-by-default snippet contents in a pre block' do
    @snippet.format = nil
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('pre', /\* whatever/)
  end

  it 'should have no pre black for formatted snippet contents' do
    @snippet.format = 'markdown'
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should_not have_tag('pre')
  end

  it 'should include an edit link' do
    do_render
    response.should have_tag('a[href=?]', edit_admin_snippet_path(@snippet))
  end
end
