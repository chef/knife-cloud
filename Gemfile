source "https://rubygems.org"

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
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
    gem "chef-zero", "~> 15"
    gem "chef", "~> 15"
  elsif Gem::Version.new(RUBY_VERSION) > Gem::Version.new("3.1")
    gem "chef-zero", "~> 15"
    gem "chef", "~> 18"
    gem "knife"
  else
    gem "chef", ">= 18.0"
    gem "knife"
  end
  gem "rspec-expectations"
  gem "rspec-mocks", "3.9.0"
  gem "rspec_junit_formatter"
  gem "fog-core"
  gem "chefstyle", "2.2.2"
end
