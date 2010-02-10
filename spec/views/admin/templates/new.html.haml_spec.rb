require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/templates/new' do
  before :each do
    assigns[:template] = @template = Template.new
  end

  def do_render
    render 'admin/templates/new'
  end

  it 'should include a template creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_template')
  end

  describe 'template creation form' do
    it 'should point to the template create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_template', admin_templates_path)
    end

    it 'should use the POST http method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_template', 'post')
    end

    it 'should have an input for the template handle' do
      do_render
      response.should have_tag('form[id=?]', 'new_template') do
        with_tag('input[type=?][name=?]', 'text', 'template[handle]')
      end
    end

    it 'should have an input for the template contents' do
      do_render
      response.should have_tag('form[id=?]', 'new_template') do
        with_tag('textarea[name=?]', 'template[contents]')
      end
    end
    
    it 'should have a preview button' do
      do_render
      response.should have_tag('form[id=?]', 'new_template') do
        with_tag('input[type=?][value=?]', 'submit', 'Preview')
      end
    end
    
    it 'should have a preview input' do
      do_render
      response.should have_tag('form[id=?]', 'new_template') do
        with_tag('input[type=?][name=?]:not([value])', 'hidden', 'preview')
      end
    end
    
    describe 'preview button' do
      it 'should set the preview input to true' do
        do_render
        response.should have_tag('form[id=?]', 'new_template') do
          with_tag('input[type=?][value=?][onclick*=?][onclick*=?]', 'submit', 'Preview', 'preview', 'true')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_template') do
        with_tag('input[type=?]:not([value=?])', 'submit', 'Preview')
      end
    end

    describe 'when errors are available' do
      it 'should display errors in an error region' do
        @template.errors.add_to_base("error on this template")
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
        @template.contents = "
 * whatever
 * whatever else
"
    end
    
    it 'should exist if the template has contents' do
      do_render
      response.should have_tag('div[id=?]', 'preview')
    end

    
    it 'should include the template contents without formatting' do
      do_render
      response.should have_tag('div[id=?]', 'preview', :text => /\* whatever/)
    end
    
    it 'should not exist if the template contents are the empty string' do
      @template.contents = ''
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the template contents are nil' do
      @template.contents = nil
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
    
    it 'should not exist if the template contents are a completely blank string' do
      @template.contents = '     '
      do_render
      response.should_not have_tag('div[id=?]', 'preview')
    end
  end
end
