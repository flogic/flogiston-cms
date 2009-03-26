require 'fileutils'

def plugin_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), relative))
end

def rails_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', relative))
end

def readme_contents
  IO.read(plugin_path('README'))
end


# remove application directories not needed in a plugin
['vendor', 'log', 'config', 'lib/tasks', 'script', 'tmp'].each do |path|
  puts "Removing plugin #{path}/ directory (#{plugin_path(path)})..."
  FileUtils.rm_rf(plugin_path(path))
end

# install our database migrations to the application
if File.directory?(rails_path('db/migrate'))
  Dir[File.join(plugin_path('db/migrate'), '*.rb')].each do |migration|
    puts "Installing plugin migration #{migration} to #{rails_path('db/migrate')}..."
    FileUtils.copy(migration, rails_path('db/migrate'))
  end
end

# run our Rails template to insure needed gems and plugins are installed
system("rake rails:template LOCATION=#{plugin_path('templates/plugin-install.rb')}")

# and output our README
puts readme_contents
