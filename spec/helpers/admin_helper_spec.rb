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
end
