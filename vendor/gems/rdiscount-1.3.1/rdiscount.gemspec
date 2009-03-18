Gem::Specification.new do |s|
  s.name = 'rdiscount'
  s.version = '1.3.1'
  s.summary = "Fast Implementation of Gruber's Markdown in C"
  s.date = '2009-01-10'
  s.email = 'r@tomayko.com'
  s.homepage = 'http://github.com/rtomayko/rdiscount'
  s.has_rdoc = true
  s.authors = ["Ryan Tomayko", "Andrew White"]
  # = MANIFEST =
  s.files = %w[
    COPYING
    README.markdown
    Rakefile
    bin/rdiscount
    ext/amalloc.h
    ext/config.h
    ext/cstring.h
    ext/docheader.c
    ext/dumptree.c
    ext/extconf.rb
    ext/generate.c
    ext/markdown.c
    ext/markdown.h
    ext/mkdio.c
    ext/mkdio.h
    ext/rbstrio.c
    ext/rbstrio.h
    ext/rdiscount.c
    ext/resource.c
    lib/markdown.rb
    lib/rdiscount.rb
    rdiscount.gemspec
    test/benchmark.rb
    test/benchmark.txt
    test/markdown_test.rb
    test/rdiscount_test.rb
  ]
  # = MANIFEST =
  s.test_files = ["test/markdown_test.rb", "test/rdiscount_test.rb"]
  s.extra_rdoc_files = ["COPYING"]
  s.extensions = ["ext/extconf.rb"]
  s.executables = ["rdiscount"]
  s.require_paths = ["lib"]
  s.rubyforge_project = 'wink'
end
