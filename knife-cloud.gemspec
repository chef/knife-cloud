# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'knife-cloud/version'

Gem::Specification.new do |s|
  s.name        = 'knife-cloud'
  s.version     = Knife::Cloud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.authors     = ['Kaustubh Deorukhkar', 'Ameya Varade']
  s.email       = ['dev@chef.io']
  s.homepage    = 'https://github.com/chef/knife-cloud'
  s.summary     = 'knife-cloud plugin'
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w(lib spec)

  s.add_dependency 'knife-windows', '>= 0.5.14'
  s.add_dependency 'chef', '>= 0.10.10'
  s.add_dependency 'mixlib-shellout'

  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter fog rubocop).each { |gem| s.add_development_dependency gem }
end
