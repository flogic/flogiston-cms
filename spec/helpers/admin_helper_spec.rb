require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))
 
describe AdminHelper do
  it 'should have a means of getting admin sections' do
    helper.should respond_to(:admin_sections)
  end
  
  describe 'admin sections' do
    it 'should include pages' do
      helper.admin_sections.should include('pages')
    end
    
    it 'should include snippets' do
      helper.admin_sections.should include('snippets')
    end
    
    it 'should include templates' do
      helper.admin_sections.should include('templates')
    end
    
    it 'should include layouts' do
      helper.admin_sections.should include('layouts')
    end
  end

  it 'should provide a list of template options' do
    helper.should respond_to(:template_options)
  end

  describe 'template options' do
    describe 'when there are no templates' do
      before do
        Template.delete_all
      end

      it 'should return the empty list' do
        helper.template_options.should == []
      end
    end

    describe 'when there are templates' do
      before do
        3.times { Template.generate! }
        @templates = Template.all
      end

      it 'should return an array of handle/id pairs for the existing templates, with a blank placeholder at the start' do
        expected = @templates.collect { |t|  [t.handle, t.id] }
        expected.unshift([])

        helper.template_options.should == expected
      end
    end
  end
end
