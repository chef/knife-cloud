# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-cloud/version"

Gem::Specification.new do |s|
  s.name        = "knife-cloud"
  s.version     = Knife::Cloud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.authors     = ["Kaustubh Deorukhkar", "Ameya Varade"]
  s.email       = ["kaustubh@clogeny.com"]
  s.homepage    = "https://github.com/opscode/knife-cloud"
  s.summary     = %q{knife-cloud plugin}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "spec"]

  s.add_dependency "fog", ">= 1.10.0"
  s.add_dependency "chef", ">= 0.10.10"
  s.add_dependency 'mixlib-shellout'
  s.add_dependency 'active_support'

  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter).each { |gem| s.add_development_dependency gem }
end
