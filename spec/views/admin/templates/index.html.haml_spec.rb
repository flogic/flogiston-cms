require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper]))

describe 'admin/templates/index' do
  before :each do
    Template.delete_all
    @templates = []
    @template_obj = Template.generate!(:handle => 'test handle')
    assigns[:templates] = [@template_obj]
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
          with_tag('tr', Regexp.new(Regexp.escape(@template_obj.handle)))
        end
      end
    end

    describe 'when the template has associated pages' do
      before do
        @count = 3
        @count.times { @template_obj.pages.generate! }
      end

      it 'should include the number of pages' do
        do_render
        response.should have_tag('table[id=?]', 'templates') do
          with_tag('tbody') do
            with_tag('tr', Regexp.new(Regexp.escape(@count.to_s)))
          end
        end
      end
    end

    describe 'when the template has no associated pages' do
      before do
        @template_obj.pages.clear
      end

      it 'should not indicate 0 pages' do
        do_render
        response.should have_tag('table[id=?]', 'templates') do
          with_tag('tbody') do
            without_tag('tr', Regexp.new(Regexp.escape('0')))
          end
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
      other_template = Template.generate!(:handle => 'some other handle')
      assigns[:templates].push(other_template)
      
      do_render
      response.should have_tag('table[id=?]', 'templates') do
        with_tag('tbody') do
          [@template_obj, other_template].each do |template|
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
