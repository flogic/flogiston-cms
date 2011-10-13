require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))
include PagesHelper

describe 'admin/templates/show' do
  before :each do
    assigns[:template_obj] = @template_obj = Template.generate!(:handle => 'test handle', :contents => 'test contents')
  end

  def do_render
    render 'admin/templates/show'
  end

  it 'should include the template handle' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@template_obj.handle)))
  end

  it 'should include the template contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@template_obj.contents)))
  end
  
  it 'should include the template contents without formatting, with entities escaped, and in a pre block' do
    @template_obj.contents = "
 * whate<ve>r
 * whatever else
"
    do_render
    response.should have_tag('pre', :text => /\* whate&lt;ve&gt;r/)
  end

  it 'should include an edit link' do
    do_render
    response.should have_tag('a[href=?]', edit_admin_template_path(@template_obj))
  end

  describe 'when the template has associated pages' do
    before :each do
      2.times { @template_obj.pages.generate! }
    end

    it 'should include a link to edit each associated page' do
      do_render
      @template_obj.pages.each do |page|
        response.should have_tag('a[href=?]', edit_admin_page_path(page))
      end
    end
  end

  describe 'when the template has no associated pages' do
    before :each do
      @template_obj.pages.clear
    end

    it 'should not include any links to edit pages' do
      do_render
      response.should_not have_tag('a[href^=?]', admin_pages_path)
    end
  end
end
