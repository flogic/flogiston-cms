require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/templates/index' do
  before :each do
    Template.delete_all
    @template_objs = []
    @template_obj = Template.generate!(:handle => 'test handle')
    assigns[:template_objs] = [@template_obj]
  end

  def do_render
    render 'admin/templates/index'
  end
  
  it 'should include a template list' do
    do_render
    response.should have_tag('table[id=?]', 'templates')
  end
  
  describe 'template_obj list' do
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
          with_tag('tr', Regexp.new(Regexp.escape(@template_obj.handle)))
        end
      end
    end
    
    it 'should include an edit link' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_template_path(@template_obj))
          end
        end
      end
    end
    
    it 'should include a delete link' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_template_path(@template_obj), 'delete')
          end
        end
      end
    end
    
    it 'should include a show link which opens the template in a new window' do
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][target=?]:not([onclick*=?])', admin_template_path(@template_obj), '_blank', 'delete')
          end
        end
      end
    end
    
    it 'should contain a row for each template' do
      other_template_obj = Template.generate!(:handle => 'some other handle')
      assigns[:template_objs].push(other_template_obj)
      
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          [@template_obj, other_template_obj].each do |template_obj|
            with_tag('tr', Regexp.new(Regexp.escape(template_obj.handle)))
          end
        end
      end
    end
    
    it 'should contain no rows if there are no templates' do
      assigns[:template_objs] = []
      
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end
