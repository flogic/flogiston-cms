require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/snippets/edit' do
  before :each do
    assigns[:snippet] = @snippet = Snippet.generate!
  end

  def do_render
    render 'admin/snippets/edit'
  end

  it 'should include a link to open the markdown syntax guide on a new snippet' do
    do_render
    response.should have_tag('a[href=?][target=?]', 'http://daringfireball.net/projects/markdown/syntax', '_blank')
  end
  
  it 'should include a snippet update form' do
    do_render
    response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}")
  end

  describe 'snippet update form' do
    it 'should point to the snippet update action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_snippet_#{@snippet.id}", admin_snippet_path(@snippet))
    end

    it 'should use the PUT http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_snippet_#{@snippet.id}", 'post') do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
    
    it 'should have an input for the snippet handle' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('input[type=?][name=?]', 'text', 'snippet[handle]')
      end
    end

    it 'should include the current snippet handle value' do
      @snippet.handle = 'test handle'
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'snippet[handle]', @snippet.handle)
      end
    end

    it 'should have an input for the snippet format' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('select[name=?]', 'snippet[format]')
      end
    end

    describe 'snippet format input' do
      before do
        @formats = [ %w[lab1 val1], %w[dee-FAULT raw], %w[blah bang] ]
        template.stubs(:page_format_options).returns(@formats)
      end

      it 'should get the layout format options' do
        template.expects(:page_format_options).returns(@formats)
        do_render
      end

      it 'should include an option for every format' do
        do_render
        response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
          with_tag('select[name=?]', 'snippet[format]') do
            @formats.each do |label, value|
              with_tag('option[value=?]', value, label)
            end
          end
        end
      end

      it 'should select the option for the snippet format' do
        @snippet.format = @formats.last.last
        do_render
        response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
          with_tag('select[name=?]', 'snippet[format]') do
            with_tag('option[value=?][selected]', @snippet.format)
          end
        end
      end

      it "should select the 'raw' option if the snippet format is nil" do
        @snippet.format = nil
        do_render
        response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
          with_tag('select[name=?]', 'snippet[format]') do
            with_tag('option[value=?][selected]', 'raw')
          end
        end
      end
    end

    it 'should have an input for the snippet contents' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('textarea[name=?]', 'snippet[contents]')
      end
    end

    it 'should include the current snippet contents value' do
      @snippet.contents = 'test contents'
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('textarea[name=?]', 'snippet[contents]', :text => Regexp.new(Regexp.escape(@snippet.contents)))
      end
    end

    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_snippet_#{@snippet.id}") do
        with_tag('input[type=?]:not([value=?])', 'submit', 'Preview')
      end
    end

    describe 'when errors are available' do
      it 'should display errors in an error region' do
        @snippet.errors.add_to_base("error on this snippet")
        do_render
        response.should have_tag('div[class=?]', 'errors', :text => /error on this snippet/)
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
      @snippet.format = 'markdown'
      @snippet.contents = "
 * whatever
 * whatever else
"
    end

    it 'should exist if the snippet has contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview')
    end

    it 'should include the snippet contents formatted according to snippet format' do
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('li', :text => /whatever/)
      end
    end

    it 'should leave snippet contents unformatted if snippet format indicates it' do
      @snippet.format = 'raw'
      do_render
      response.should have_tag('div[id=?]', 'preview', /\* whatever/)
    end

    it 'should contain unformatted snippet contents in a pre block' do
      @snippet.format = 'raw'
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('pre', /\* whatever/)
      end
    end

    it 'should contain unformatted-by-default snippet contents in a pre block' do
      @snippet.format = nil
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('pre', /\* whatever/)
      end
    end

    it 'should have no pre black for formatted snippet contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        without_tag('pre')
      end
    end

    it 'should not exist if the snippet contents are the empty string' do
      @snippet.contents = ''
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end

    it 'should not exist if the snippet contents are nil' do
      @snippet.contents = nil
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end

    it 'should not exist if the snippet contents are a completely blank string' do
      @snippet.contents = '     '
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
  end
end
