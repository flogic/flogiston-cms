require 'fileutils'

def plugin_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), relative))
end

def rails_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', relative))
end

def readme_contents
  IO.read(plugin_path('README.markdown'))
end

puts "Copying in plugin-specific routes..."
unless File.directory?(rails_path('config'))
  FileUtils.mkdir(rails_path('config'))
end

if File.file?(rails_path('config/routes.rb'))
  puts "Appending plugin-specific routes to #{rails_path('config/routes.rb')}..."
  File.open(rails_path('config/routes.rb'), 'a') do |f|
    f.puts
    f.puts File.read(plugin_path('lib/plugin-bottom-routes.rb'))
  end
else
  puts "Copying in plugin-specific routes to #{rails_path('config/routes.rb')}..."
  FileUtils.copy(plugin_path('lib/plugin-bottom-routes.rb'), rails_path('config/routes.rb'))
end

puts "Installing plugin migrations"
FileUtils.cp_r(plugin_path('db/migrate'), rails_path('db'))

# run our Rails template to insure needed gems and plugins are installed
system("rake rails:template LOCATION=#{plugin_path('templates/plugin-install.rb')}")

# and output our README
puts readme_contents
