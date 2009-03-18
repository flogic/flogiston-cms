run("rm -rf test/")

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
generate("rspec")

plugin 'object_daddy', :git => 'git://github.com/flogic/object_daddy.git'

gem 'rdiscount'
gem 'mocha'
gem 'haml'

rake("gems:install")
rake("gems:unpack")
rake("gems:build")
rake("db:migrate")
rake("db:test:prepare")

file '.gitignore',
%q{coverage/*
log/*.log
log/*.pid
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
.DS_Store
doc/api
doc/app
config/database.yml
spec/spec.opts
spec/rcov.opts
public/javascripts/all.js
public/stylesheets/all.js
.dotest/*
}

file 'spec/spec.opts', <<-EOF
--colour
--format
s
--loadby
mtime
--reverse
EOF

run "cp config/database.yml config/database.yml.example"
run "cp spec/spec.opts spec/spec.opts.example"
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

