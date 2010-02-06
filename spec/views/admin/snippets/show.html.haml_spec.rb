require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

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

  it 'should format the snippet contents with markdown' do
    @snippet.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_tag('li', :text => /whatever/)
  end
end
