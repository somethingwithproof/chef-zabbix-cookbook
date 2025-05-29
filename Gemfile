source 'https://rubygems.org'

gem 'chef', '~> 19.0'
gem 'berkshelf', '>= 8.0'

group :development do
  gem 'chef-cli', '~> 5.6'
  gem 'cookstyle', '~> 8.1'
  gem 'chefspec', '~> 9.3'
  gem 'kitchen-inspec', '~> 3.0'
  gem 'kitchen-dokken', '~> 2.20'
  gem 'test-kitchen', '~> 3.7'
  # gem 'ruby-shadow' # For user resources - requires compilation
end

group :test do
  gem 'rspec', '~> 3.12'
  gem 'rspec_junit_formatter'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'github-markup'
  gem 'inspec', '~> 7.0'
  gem 'inspec-bin', '~> 5.22'
  gem 'kitchen-vagrant'
  gem 'concurrent-ruby'
end

group :docs do
  gem 'yard'
  gem 'redcarpet'
end