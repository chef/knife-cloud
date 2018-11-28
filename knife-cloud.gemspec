# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "knife-cloud/version"

Gem::Specification.new do |s|
  s.name        = "knife-cloud"
  s.version     = Knife::Cloud::VERSION
  s.authors     = ["Kaustubh Deorukhkar", "Ameya Varade"]
  s.email       = ["dev@chef.io"]
  s.homepage    = "https://github.com/chef/knife-cloud"
  s.summary     = "knife-cloud plugin"
  s.description = s.summary

  s.files         = %w{LICENSE} + Dir.glob("lib/**/*")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = %w{lib}
  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency "knife-windows", ">= 1.0"
  s.add_dependency "mixlib-shellout"
  s.add_dependency "excon", ">=  0.50" # excon 0.50 renamed the errors class and required updating rescues
end
