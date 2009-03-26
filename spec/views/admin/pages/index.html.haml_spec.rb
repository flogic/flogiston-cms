require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/pages/index' do
  before :each do
    Page.delete_all
    @pages = []
    @page = Page.generate!(:title => 'test title')
    assigns[:pages] = [@page]
  end

  def do_render
    render 'admin/pages/index'
  end
  
  it 'should include a page list' do
    do_render
    response.should have_tag('table[id=?]', 'pages')
  end
  
  describe 'page list' do
    it 'should have a row for the page' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr')
        end
      end
    end
    
    it 'should include the page title' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(@page.title)))
        end
      end
    end
    
    it 'should include the page handle' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(@page.handle)))
        end
      end
    end
    
    it 'should get a marker for the possibly-invalid page handle' do
      template.expects(:show_invalid_handle).with(@page)
      do_render
    end
    
    it 'should include the possible invalid page handle marker' do
      marker = 'bad page marker'
      template.stubs(:show_invalid_handle).returns(marker)
      
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(marker)))
        end
      end
    end
    
    it 'should include an edit link' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_page_path(@page))
          end
        end
      end
    end
    
    it 'should include a delete link' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_page_path(@page), 'delete')
          end
        end
      end
    end
    
    it 'should include a show link which opens the page in a new window' do
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][target=?]:not([onclick*=?])', '/'+@page.handle, '_blank', 'delete')
          end
        end
      end
    end
    
    it 'should contain a row for each page' do
      other_page = Page.generate!(:title => 'Some Other Title')
      assigns[:pages].push(other_page)
      
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          [@page, other_page].each do |page|
            with_tag('tr', Regexp.new(Regexp.escape(page.title)))
          end
        end
      end
    end
    
    it 'should contain no rows if there are no pages' do
      assigns[:pages] = []
      
      do_render
      response.should have_tag('table[id=?]', 'pages') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end
