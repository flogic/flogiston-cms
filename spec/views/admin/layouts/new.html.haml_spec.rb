require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/layouts/new' do
  before :each do
    assigns[:layout] = @layout = Layout.new
  end

  def do_render
    render 'admin/layouts/new'
  end

  it 'should include a layout creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_layout')
  end

  describe 'layout creation form' do
    it 'should point to the layout create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_layout', admin_layouts_path)
    end

    it 'should use the POST http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_layout', 'post')
    end

    it 'should have an input for the layout handle' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('input[type=?][name=?]', 'text', 'layout[handle]')
      end
    end

    it 'should have an input for the layout format' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('select[name=?]', 'layout[format]')
      end
    end

    describe 'layout format input' do
      before do
        @formats = [ %w[lab1 val1], %w[blah bang] ]
        template.stubs(:layout_format_options).returns(@formats)
      end

      it 'should get the layout format options' do
        template.expects(:layout_format_options).returns(@formats)
        do_render
      end

      it 'should include an option for every format' do
        do_render
        response.should have_tag('form[id=?]', 'new_layout') do
          with_tag('select[name=?]', 'layout[format]') do
            @formats.each do |label, value|
              with_tag('option[value=?]', value, label)
            end
          end
        end
      end
    end

    it 'should have an input for the layout contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('textarea[name=?]', 'layout[contents]')
      end
    end
    
    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', 'new_layout') do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_layout') do
        with_tag('input[type=?]:not([value=?])', 'submit', 'Preview')
      end
    end

    describe 'when errors are available' do
      it 'should display errors in an error region' do
        @layout.errors.add_to_base("error on this layout")
        do_render
        response.should have_tag('div[class=?]', 'errors', :text => /error on this layout/)
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
        @layout.contents = "
 * whate<ve>r
 * whatever else
"
    end
    
    it 'should exist if the layout has contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview')
    end
    
    it 'should include the layout contents without formatting, with entities escaped, and in a pre block' do
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('pre', :text => /\* whate&lt;ve&gt;r/)
      end
    end
    
    it 'should not exist if the layout contents are the empty string' do
      @layout.contents = ''
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the layout contents are nil' do
      @layout.contents = nil
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the layout contents are a completely blank string' do
      @layout.contents = '     '
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
  end
end
