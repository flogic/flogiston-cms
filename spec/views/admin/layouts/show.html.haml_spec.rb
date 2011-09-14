require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))
include PagesHelper

describe 'admin/layouts/show' do
  before :each do
    assigns[:layout] = @layout = Layout.generate!(:handle => 'test handle', :contents => 'test contents')
  end

  def do_render
    render 'admin/layouts/show'
  end

  it 'should include the layout handle' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@layout.handle)))
  end

  it 'should include the layout contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@layout.contents)))
  end
  
  it 'should include the layout contents without formatting, with entities escaped, and in a pre block' do
    @layout.contents = "
 * whate<ve>r
 * whatever else
"
    do_render
    response.should have_tag('pre', :text => /\* whate&lt;ve&gt;r/)
  end

  it 'should include an edit link' do
    do_render
    response.should have_tag('a[href=?]', edit_admin_layout_path(@layout))
  end
end
