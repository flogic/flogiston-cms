require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))
 
describe AdminHelper do
  it 'should have a means of getting admin sections' do
    helper.should respond_to(:admin_sections)
  end
  
  describe 'admin sections' do
    it 'should include pages' do
      helper.admin_sections.should include('pages')
    end
  end
end
