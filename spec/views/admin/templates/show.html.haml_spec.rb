require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))
include PagesHelper

describe 'admin/templates/show' do
  before :each do
    assigns[:template] = @template = Template.generate!(:handle => 'test handle', :contents => 'test contents')
  end

  def do_render
    render 'admin/templates/show'
  end

  it 'should include the template handle' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@template.handle)))
  end

  it 'should include the template contents' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@template.contents)))
  end

  it 'should not format the template contents' do
    @template.contents = "
 * whatever
 * whatever else
"
    do_render
    response.should have_text(/\* whatever/)
  end
end
