require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe 'admin/index' do
  def do_render
    render 'admin/index'
  end

  it 'should be valid' do
    do_render
  end  
end
