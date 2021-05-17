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
  gem "rspec-core"
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
    gem "chef-zero", "~> 15"
    gem "chef", "~> 16"
  else
    gem "chef", "~> 16"
  end
  gem "rspec-expectations"
  gem "rspec-mocks"
  gem "rspec_junit_formatter"
  gem "fog-core"
  gem "chefstyle", "1.7.5"
end
