require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/new' do
  before :each do
    assigns[:page] = @page = Page.new
  end

  def do_render
    render 'admin/pages/new'
  end

  it 'should include a link to the markdown syntax guide' do
    do_render
    response.should have_tag('a[href=?][target=?]', 'http://daringfireball.net/projects/markdown/syntax', '_blank')
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

    it 'should have an input for the page template' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('select[name=?]', 'page[template_id]')
      end
    end

    describe 'page template input' do
      describe 'when templates exist' do
        before do
          3.times { Template.generate! }
          @templates = Template.all
        end

        it 'should have a blank placeholder option' do
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            with_tag('select[name=?]', 'page[template_id]') do
              with_tag('option[value=?]', '', '')
            end
          end
        end

        it 'should have an option for every template' do
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            with_tag('select[name=?]', 'page[template_id]') do
              @templates.each do |template|
                with_tag('option[value=?]', template.id.to_s, template.handle)
              end
            end
          end
        end
      end

      describe 'when no templates exist' do
        before do
          Template.delete_all
        end

        it 'should have no options' do
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            with_tag('select[name=?]', 'page[template_id]') do
              without_tag('option')
            end
          end
        end
      end
    end

    describe 'when the page has a template' do
      before do
        @page.template = Template.generate!
      end

      describe 'and the template has replacements' do
        before do
          @replacements = %w[some stuff here]
          @page.template.stubs(:replacements).returns(@replacements)
        end

        it 'should have a value input for every replacement' do
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            @replacements.each do |r|
              with_tag('input[name=?]', "page[values][#{r}]")
            end
          end
        end

        it 'should include the replacement value if set' do
          @page.values = { 'stuff' => 'blah' }
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            with_tag('input[name=?][value=?]', 'page[values][stuff]', 'blah')
          end
        end
      end

      describe 'and the template has no replacements' do
        before do
          @page.template.stubs(:replacements).returns([])
        end

        it 'should have no replacement value inputs' do
          do_render
          response.should have_tag('form[id=?]', 'new_page') do
            without_tag('input[name^=?]', 'page[values]')
          end
        end
      end
    end

    describe 'when the page has no template' do
      before do
        @page.template = nil
      end

      it 'should have no replacement value inputs' do
        do_render
        response.should have_tag('form[id=?]', 'new_page') do
          without_tag('input[name^=?]', 'page[values]')
        end
      end
    end

    it 'should have an input for the page contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('textarea[name=?]', 'page[contents]')
      end
    end

    it 'should have an input for the page contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('textarea[name=?]', 'page[contents]')
      end
    end
    
    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', 'new_page') do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_page') do
        with_tag('input[type=?]:not([value=?])', 'submit', 'Preview')
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
  
  describe 'preview area' do
    before :each do
        @page.contents = "
 * whatever
 * whatever else
"
    end
    
    it 'should exist if the page has contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview')
    end

    
    it 'should include the page contents formatted with markdown' do
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('li', :text => /whatever/)
      end
    end
    
    it 'should include referenced snippets' do
      Snippet.generate!(:handle => 'testsnip', :contents => "
 1. something
 1. nothing
      ")
      @page.contents += "\n{{ testsnip }}\n"
      
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('li', :text => /something/)
      end
    end
    
    it 'should not exist if the page contents are the empty string' do
      @page.contents = ''
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the page contents are nil' do
      @page.contents = nil
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the page contents are a completely blank string' do
      @page.contents = '     '
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
  end
end
