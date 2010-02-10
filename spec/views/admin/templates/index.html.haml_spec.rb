require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/templates/index' do
  before :each do
    Template.delete_all
    @templates = []
    @template = Template.generate!(:handle => 'test handle')
    assigns[:templates] = [@template]
  end

  def do_render
    render 'admin/templates/index'
  end
  
  it 'should include a template list' do
    do_render
    response.should have_tag('table[id=?]', 'templates')
  end
  
  describe 'template list' do
    it 'should have a row for the template' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr')
        end
      end
    end
    
    it 'should include the template handle' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr', Regexp.new(Regexp.escape(@template.handle)))
        end
      end
    end
    
    it 'should include an edit link' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_template_path(@template))
          end
        end
      end
    end
    
    it 'should include a delete link' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_template_path(@template), 'delete')
          end
        end
      end
    end
    
    it 'should include a show link which opens the template in a new window' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][target=?]:not([onclick*=?])', admin_template_path(@template), '_blank', 'delete')
          end
        end
      end
    end
    
    it 'should contain a row for each template' do
      other_template = Template.generate!(:handle => 'some other handle')
      assigns[:templates].push(other_template)
      
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          [@template, other_template].each do |template|
            with_tag('tr', Regexp.new(Regexp.escape(template.handle)))
          end
        end
      end
    end
    
    it 'should contain no rows if there are no templates' do
      assigns[:templates] = []
      
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end