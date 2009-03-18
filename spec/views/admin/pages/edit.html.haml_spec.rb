require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/edit' do
  before :each do
    assigns[:page] = @page = Page.generate!
  end

  def do_render
    render 'admin/pages/edit'
  end

  it 'should include a link to the markdown syntax guide' do
    do_render
    response.should have_tag('a[href=?]', 'http://daringfireball.net/projects/markdown/syntax')
  end
  
  it 'should include a page update form' do
    do_render
    response.should have_tag('form[id=?]', "edit_page_#{@page.id}")
  end

  describe 'page creation form' do
    it 'should point to the page create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_page_#{@page.id}", admin_page_path(@page))
    end

    it 'should use the PUT http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_page_#{@page.id}", 'post') do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end

    it 'should have an input for the page title' do
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('input[type=?][name=?]', 'text', 'page[title]')
      end
    end

    it 'should include the current page title value' do
      @page.title = 'test title'
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'page[title]', @page.title)
      end
    end

    it 'should have an input for the page handle' do
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('input[type=?][name=?]', 'text', 'page[handle]')
      end
    end

    it 'should include the current page handle value' do
      @page.handle = 'test handle'
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'page[handle]', @page.handle)
      end
    end

    it 'should have an input for the page contents' do
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('textarea[name=?]', 'page[contents]')
      end
    end

    it 'should include the current page contents value' do
      @page.contents = 'test contents'
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
        with_tag('textarea[name=?]', 'page[contents]', :text => Regexp.new(Regexp.escape(@page.contents)))
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_page_#{@page.id}") do
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
