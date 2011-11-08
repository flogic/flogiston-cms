plugin 'flogiston', :git => 'git://github.com/flogic/flogiston.git'

Dir["#{RAILS_ROOT}/vendor/plugins/flogiston-cms/app/models/flogiston/*.rb"].each do |f|
  filename = File.basename(f, '.rb')
  model_name = filename.camelize

  if File.exist?("app/models/#{filename}.rb")
    puts "*** model #{filename}.rb exists. Ensure it defines #{model_name} < Flogiston::#{model_name}. ***"
  else
    file "app/models/#{filename}.rb", <<-eof
class #{model_name} < Flogiston::#{model_name}
end
    eof
  end
end

Dir["#{RAILS_ROOT}/vendor/plugins/flogiston-cms/app/controllers/flogiston/**/*.rb"].each do |f|
  # not basename, since I want to preserve the subdir
  filename = f.sub(Regexp.new("^#{RAILS_ROOT}/vendor/plugins/flogiston-cms/app/controllers/flogiston/"), '')
  filename.sub!(/\.rb$/, '')
  controller_name = filename.camelize

  if File.exist?("app/controllers/#{filename}.rb")
    puts "*** controller #{filename}.rb exists. Ensure it defines #{controller_name} < Flogiston::#{controller_name}. ***"
  else
    file "app/controllers/#{filename}.rb", <<-eof
class #{controller_name} < Flogiston::#{controller_name}
end
    eof
  end
end

gem 'rdiscount'

rake 'gems:install'
rake 'gems:unpack'
rake 'gems:build'
