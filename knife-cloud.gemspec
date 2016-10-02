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
  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency 'knife-windows', '>= 1.0'
  s.add_dependency 'chef',  '>= 12.0'
  s.add_dependency 'mixlib-shellout'
  s.add_dependency 'excon', '>=  0.50' # excon 0.50 renamed the errors class and required updating rescues
end
