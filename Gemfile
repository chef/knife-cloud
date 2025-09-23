source "https://rubygems.org"

source "https://artifactory-internal.ps.chef.co/artifactory/api/gems/omnibus-gems-local" do
  gem "chef", ">= 19.1"
end
gem 'knife', git: 'https://github.com/chef/knife.git', branch: 'main'
# Specify your gem's dependencies in knife-cloud.gemspec
gemspec

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :test do
  gem "rake"
  gem "rspec-core", "~> 3.9"
  gem "chef-zero", "~> 15"
  gem "knife"
  gem "rspec-expectations"
  gem "rspec-mocks", "3.9.0"
  gem "rspec_junit_formatter"
  gem "fog-core"
  gem "chefstyle", "2.2.2"
end
