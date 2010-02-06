require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/snippets/index' do
  before :each do
    Snippet.delete_all
    @snippets = []
    @snippet = Snippet.generate!(:handle => 'test handle')
    assigns[:snippets] = [@snippet]
  end

  def do_render
    render 'admin/snippets/index'
  end
  
  it 'should include a snippet list' do
    do_render
    response.should have_tag('table[id=?]', 'snippets')
  end
  
  describe 'snippet list' do
    it 'should have a row for the snippet' do
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          with_tag('tr')
        end
      end
    end
    
    it 'should include the snippet handle' do
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(@snippet.handle)))
        end
      end
    end
    
    it 'should include an edit link' do
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_snippet_path(@snippet))
          end
        end
      end
    end
    
    it 'should include a delete link' do
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_snippet_path(@snippet), 'delete')
          end
        end
      end
    end
    
    it 'should include a show link which opens the snippet in a new window' do
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][target=?]:not([onclick*=?])', admin_snippet_path(@snippet), '_blank', 'delete')
          end
        end
      end
    end
    
    it 'should contain a row for each snippet' do
      other_snippet = Snippet.generate!(:handle => 'some other handle')
      assigns[:snippets].push(other_snippet)
      
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          [@snippet, other_snippet].each do |snippet|
            with_tag('tr', Regexp.new(Regexp.escape(snippet.handle)))
          end
        end
      end
    end
    
    it 'should contain no rows if there are no snippets' do
      assigns[:snippets] = []
      
      do_render
      response.should have_tag('table[id=?]', 'snippets') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end
