require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/new' do
  before :each do
    assigns[:page] = @page = Page.new
  end

  def do_render
    render 'admin/pages/new'
  end

  it 'should include a page creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_page')
  end

  describe 'page creation form' do
    it 'should point to the page create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_page', admin_pages_path)
    end

    it 'should use the POST http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_page', 'post')
    end

    it 'should have an input for the page title' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?][name=?]', 'text', 'page[title]')
      end
    end

    it 'should have an input for the page handle' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?][name=?]', 'text', 'page[handle]')
      end
    end

    it 'should have an input for the page contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('textarea[name=?]', 'page[contents]')
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?]', 'submit')
      end
    end

    describe 'when errors are available' do
      it 'should display errors in an error region' do
        @page.errors.add_to_base("error on this page")
        do_render
        response.should have_tag('div[class=?]', 'errors', :text => /error on this page/)
      end
    end

    describe 'when no errors are available' do
      it 'should not display errors' do
        do_render
        response.should_not have_tag('div[class=?]', 'errors')
      end
    end
  end
end
