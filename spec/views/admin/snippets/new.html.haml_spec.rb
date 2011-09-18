require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/snippets/new' do
  before :each do
    assigns[:snippet] = @snippet = Snippet.new
  end

  def do_render
    render 'admin/snippets/new'
  end

  it 'should include a link to the markdown syntax guide' do
    do_render
    response.should have_tag('a[href=?][target=?]', 'http://daringfireball.net/projects/markdown/syntax', '_blank')
  end
  
  it 'should include a snippet creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_snippet')
  end

  describe 'snippet creation form' do
    it 'should point to the snippet create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_snippet', admin_snippets_path)
    end

    it 'should use the POST http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_snippet', 'post')
    end

    it 'should have an input for the snippet handle' do
      do_render
      response.should have_tag('form[id=?]', 'new_snippet') do
        with_tag('input[type=?][name=?]', 'text', 'snippet[handle]')
      end
    end

    it 'should have an input for the snippet contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_snippet') do
        with_tag('textarea[name=?]', 'snippet[contents]')
      end
    end
    
    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', 'new_snippet') do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', 'new_snippet') do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', 'new_snippet') do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_snippet') do
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
