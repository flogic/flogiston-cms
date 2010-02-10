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

  it 'should not format the template contents' do
    @template_obj.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_text(/\* whatever/)
  end
end
