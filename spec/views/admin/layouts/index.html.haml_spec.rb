require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/layouts/index' do
  before :each do
    Layout.delete_all
    @layouts = []
    @layout = Layout.generate!(:handle => 'test handle')
    assigns[:layouts] = [@layout]
  end

  def do_render
    render 'admin/layouts/index'
  end
  
  it 'should include a layout list' do
    do_render
    response.should have_tag('table[id=?]', 'layouts')
  end
  
  describe 'layout list' do
    it 'should have a row for the layout' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr')
        end
      end
    end
    
    it 'should include the layout handle' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(@layout.handle)))
        end
      end
    end

    it 'should include a default marker if this layout is the default' do
      @layout.default = true
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape('(default)')))
        end
      end
    end

    it 'should not include a default marker if this layout is not the default' do
      @layout.default = false
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          without_tag('tr', Regexp.new(Regexp.escape('(default)')))
        end
      end
    end
    
    it 'should include an edit link' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_layout_path(@layout))
          end
        end
      end
    end
    
    it 'should include a delete link' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_layout_path(@layout), 'delete')
          end
        end
      end
    end

    it 'should include a make-default link' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', default_admin_layout_path(@layout), 'put')
          end
        end
      end
    end

    it 'should include a show link which opens the layout in a new window' do
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][target=?]:not([onclick*=?])', admin_layout_path(@layout), '_blank', 'delete')
          end
        end
      end
    end
    
    it 'should contain a row for each layout' do
      other_layout = Layout.generate!(:handle => 'some other handle')
      assigns[:layouts].push(other_layout)
      
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          [@layout, other_layout].each do |layout|
            with_tag('tr', Regexp.new(Regexp.escape(layout.handle)))
          end
        end
      end
    end
    
    it 'should contain no rows if there are no layouts' do
      assigns[:layouts] = []
      
      do_render
      response.should have_tag('table[id=?]', 'layouts') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end
