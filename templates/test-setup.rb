require 'fileutils'

def plugin_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'flogiston-cms', relative))
end

def rails_path(relative)
  plugin_path('../../../spec/exemplars')
end

plugin 'object_daddy', :git => 'git://github.com/flogic/object_daddy.git'

gem 'mocha'

# install object_daddy exemplar files in main spec/exemplars/ path
Dir[plugin_path('spec/exemplars') + '/*.rb'].each do |exemplar|
  puts "Copying plugin exemplar [#{exemplar}] to [#{rails_path('spec/exemplars')}]..."
  FileUtils.copy(exemplar, rails_path('spec/exemplars'))
end