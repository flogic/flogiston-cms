require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))
require 'fileutils'

def plugin_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', relative))
end

def rails_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', relative))
end

describe 'the plugin install.rb script' do
  before :each do
    FileUtils.stubs(:rm_rf)
    FileUtils.stubs(:mkdir)
    FileUtils.stubs(:copy)
    FileUtils.stubs(:cp_r)
    File.stubs(:directory?).returns(true)
    self.stubs(:system).returns(true)
    self.stubs(:puts).returns(true)
  end

  def do_install
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. .. install.rb ]))
  end

  it "should remove the plugin's vendor/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('vendor'))
    do_install
  end

  it "should remove the plugin's log/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('log'))
    do_install
  end

  it "should remove the plugin's config/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('config'))
    do_install
  end

  it "should remove the plugin's lib/tasks/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('lib/tasks'))
    do_install
  end

  it "should remove the plugin's script/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('script'))
    do_install
  end

  it "should remove the plugin's tmp/ directory" do
    FileUtils.expects(:rm_rf).with(plugin_path('tmp'))
    do_install
  end

  it 'should create a new config directory' do
    FileUtils.expects(:mkdir).with(plugin_path('config'))
    do_install
  end

  it 'should copy in the plugin routes file to the new config directory' do
    FileUtils.expects(:copy).with(plugin_path('lib/plugin-routes.rb'), plugin_path('config/routes.rb'))
    do_install
  end

  it 'should copy in the stylesheets to the public/ directory' do
      FileUtils.expects(:cp_r).with(plugin_path('public/stylesheets/sass'), rails_path('public/stylesheets'))
    do_install
  end

  describe 'when a RAILS_ROOT/db/migrate directory does not exist' do
    before :each do
      File.stubs(:directory?).with(rails_path('db/migrate')).returns(false)
    end

    it 'should create RAILS_ROOT/db/migrate when RAILS_ROOT/db exists' do
      File.stubs(:directory?).with(rails_path('db')).returns(true)
      FileUtils.expects(:mkdir).with(rails_path('db/migrate'))
      do_install
    end

    it 'should not create RAILS_ROOT/db/migrate when RAILS_ROOT/db does not exist' do
      File.stubs(:directory?).with(rails_path('db')).returns(false)
      FileUtils.expects(:mkdir).with(rails_path('db/migrate')).never
      do_install
    end

    describe 'when a RAILS_ROOT/db/migrate directory does not exist' do
      it "should not copy the plugin's db migrations to the RAILS_ROOT db/migrate directory" do
        Dir[File.join(plugin_path('db/migrate'), '*.rb')].each do |migration|
          FileUtils.expects(:copy).with(migration, rails_path('db/migrate')).never
        end
        do_install
      end
    end

    describe 'when a RAILS_ROOT/db/migrate directory exists' do
      it "should copy the plugin's db migrations to the RAILS_ROOT db/migrate directory" do
        File.stubs(:directory?).with(rails_path('db/migrate')).returns(true)
        File.stubs(:directory?).with(rails_path('db')).returns(true)
        Dir[File.join(plugin_path('db/migrate'), '*.rb')].each do |migration|
          FileUtils.expects(:copy).with(migration, rails_path('db/migrate'))
        end
        do_install
      end
    end

    it "should have rails run the plugin installation template" do
      self.expects(:system).with("rake rails:template LOCATION=#{plugin_path('templates/plugin-install.rb')}")
      do_install
    end

    it 'should display the contents of the plugin README file' do
      self.stubs(:readme_contents).returns('README CONTENTS')
      self.expects(:puts).with('README CONTENTS')
      do_install
    end

    describe 'readme_contents' do
      it 'should work without arguments' do
        do_install
        lambda { readme_contents }.should_not raise_error(ArgumentError)
      end

      it 'should accept no arguments' do
        do_install
        lambda { readme_contents(:foo) }.should raise_error(ArgumentError)
      end

      it 'should read the plugin README file' do
        do_install
        IO.expects(:read).with(plugin_path('README'))
        readme_contents
      end

      it 'should return the contents of the plugin README file' do
        do_install
        IO.stubs(:read).with(plugin_path('README')).returns('README CONTENTS')
        readme_contents.should == 'README CONTENTS'
      end
    end
  end
end
