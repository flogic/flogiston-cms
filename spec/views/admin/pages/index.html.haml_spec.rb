require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/index' do
  before :each do
    Page.delete_all
    @pages = []
    1.upto(3) do |i|
      @pages << Page.generate!(:title => "test title #{i}")
    end
    assigns[:pages] = @pages
  end

  def do_render
    render 'admin/pages/index'
  end

  it 'should include the page title for each page' do
    do_render
    @pages.each do |page|
      response.should have_text(Regexp.new(Regexp.escape(page.title)))
    end
  end

  it 'should include the page handle for each page' do
    do_render
    @pages.each do |page|
      response.should have_text(Regexp.new(Regexp.escape(page.handle)))
    end
  end

  it 'should include an edit link for each page' do
    do_render
    @pages.each do |page|
      response.should have_tag('a[href=?]', edit_admin_page_path(page))
    end
  end

  it 'should include a show link for each page' do
    do_render
    @pages.each do |page|
      response.should have_tag('a[href=?]:not([onclick*=?])', admin_page_path(page), 'delete')
    end
  end

  it 'should include a delete link for each page' do
    do_render
    @pages.each do |page|
      response.should have_tag('a[href=?][onclick*=?]', admin_page_path(page), 'delete')
    end
  end
end
