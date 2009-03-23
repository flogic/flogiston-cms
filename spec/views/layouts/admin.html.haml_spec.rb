require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe 'layouts/admin.html' do
  def do_render
    render 'layouts/admin.html.haml'
  end
  
  it 'should include a link to the pages list' do
    do_render
    response.should have_tag('a[href=?]', admin_pages_path)
  end
  
  it 'should include a link to create a new page' do
    do_render
    response.should have_tag('a[href=?]', new_admin_page_path)
  end
end
