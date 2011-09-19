require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/layouts/edit' do
  before :each do
    assigns[:layout] = @layout = Layout.generate!
  end

  def do_render
    render 'admin/layouts/edit'
  end

  it 'should include a layout update form' do
    do_render
    response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}")
  end

  describe 'layout update form' do
    it 'should point to the layout update action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_layout_#{@layout.id}", admin_layout_path(@layout))
    end

    it 'should use the PUT http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_layout_#{@layout.id}", 'post') do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
    
    it 'should have an input for the layout handle' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('input[type=?][name=?]', 'text', 'layout[handle]')
      end
    end

    it 'should include the current layout handle value' do
      @layout.handle = 'test handle'
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'layout[handle]', @layout.handle)
      end
    end

    it 'should have an input for the layout format' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('select[name=?]', 'layout[format]')
      end
    end

    describe 'layout format input' do
      before do
        @formats = [ %w[lab1 val1], %w[dee-FAULT erb], %w[blah bang] ]
        template.stubs(:layout_format_options).returns(@formats)
      end

      it 'should get the layout format options' do
        template.expects(:layout_format_options).returns(@formats)
        do_render
      end

      it 'should include an option for every format' do
        do_render
        response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
          with_tag('select[name=?]', 'layout[format]') do
            @formats.each do |label, value|
              with_tag('option[value=?]', value, label)
            end
          end
        end
      end

      it 'should select a selected option for the layout format' do
        @layout.format = @formats.last.last
        do_render
        response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
          with_tag('select[name=?]', 'layout[format]') do
            with_tag('option[value=?][selected]', @layout.format)
          end
        end
      end

      it "should select the 'erb' option if the layout format is nil" do
        @layout.format = nil
        do_render
        response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
          with_tag('select[name=?]', 'layout[format]') do
            with_tag('option[value=?][selected]', 'erb')
          end
        end
      end
    end

    it 'should have an input for the layout contents' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('textarea[name=?]', 'layout[contents]')
      end
    end

    it 'should include the current layout contents value' do
      @layout.contents = 'test contents'
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('textarea[name=?]', 'layout[contents]', :text => Regexp.new(Regexp.escape(@layout.contents)))
      end
    end

    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_layout_#{@layout.id}") do
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
