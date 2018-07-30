# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.

require "bundler"
Bundler::GemHelper.install_tasks

require "rubygems"
require "rubygems/package_task"

# Packaging
GEM_NAME = "knife-cloud".freeze
require File.dirname(__FILE__) + "/lib/knife-cloud/version"
spec = eval(File.read("knife-cloud.gemspec"))
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "uninstall #{GEM_NAME}-#{Knife::Cloud::VERSION}.gem from system..."
task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{Knife::Cloud::VERSION} }
end

# rspec
begin
  require "rspec/core/rake_task"

  desc "Run all specs in spec directory"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = "spec/unit/**/*_spec.rb"
  end

rescue LoadError
  STDERR.puts "\n*** RSpec not available. (sudo) gem install rspec to run unit tests. ***\n\n"
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle/rubocop is not available. bundle install first to make sure all dependencies are installed."
end

begin
  require "yard"
  YARD::Rake::YardocTask.new(:docs)
rescue LoadError
  puts "yard is not available. bundle install first to make sure all dependencies are installed."
end

task default: [:spec, :style]
