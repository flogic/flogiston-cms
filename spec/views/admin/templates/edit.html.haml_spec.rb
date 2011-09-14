require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/templates/edit' do
  before :each do
    assigns[:template_obj] = @template_obj = Template.generate!
  end

  def do_render
    render 'admin/templates/edit'
  end

  it 'should include a template update form' do
    do_render
    response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}")
  end

  describe 'template update form' do
    it 'should point to the template update action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_template_#{@template_obj.id}", admin_template_path(@template_obj))
    end

    it 'should use the PUT http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_template_#{@template_obj.id}", 'post') do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
    
    it 'should have an input for the template handle' do
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('input[type=?][name=?]', 'text', 'template[handle]')
      end
    end

    it 'should include the current template handle value' do
      @template_obj.handle = 'test handle'
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'template[handle]', @template_obj.handle)
      end
    end

    it 'should have an input for the template contents' do
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('textarea[name=?]', 'template[contents]')
      end
    end

    it 'should include the current template contents value' do
      @template_obj.contents = 'test contents'
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('textarea[name=?]', 'template[contents]', :text => Regexp.new(Regexp.escape(@template_obj.contents)))
      end
    end

    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_template_#{@template_obj.id}") do
        with_tag('input[type=?]:not([value=?])', 'submit', 'Preview')
      end
    end

    describe 'when errors are available' do
      it 'should display errors in an error region' do
        @template_obj.errors.add_to_base("error on this template")
        do_render
        response.should have_tag('div[class=?]', 'errors', :text => /error on this template/)
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
        @template_obj.contents = "
 * whate<ve>r
 * whatever else
"
    end

    it 'should exist if the template has contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview')
    end
    
    it 'should include the template contents without formatting, with entities escaped, and in a pre block' do
      do_render
      response.should have_tag('div[id=?]', 'preview') do
        with_tag('pre', :text => /\* whate&lt;ve&gt;r/)
      end
    end
    
    it 'should not exist if the template contents are the empty string' do
      @template_obj.contents = ''
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end

    it 'should not exist if the template contents are nil' do
      @template_obj.contents = nil
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end

    it 'should not exist if the template contents are a completely blank string' do
      @template_obj.contents = '     '
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
  end
end
