source 'https://rubygems.org'

gem 'chef', '~> 18.8'
gem 'berkshelf', '>= 8.0'

group :development do
gem 'chef-cli', '~> 5.6'
  gem 'cookstyle', '~> 8.1'
  gem 'chefspec', '~> 9.3'
  gem 'kitchen-inspec', '~> 3.0'
  gem 'kitchen-dokken', '~> 2.20'
  gem 'test-kitchen', '~> 3.7'
  gem 'rake', '~> 13.0'
end

group :test do
  # Pin RSpec to version compatible with ChefSpec 9.3
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-expectations', '~> 3.12.0'
  gem 'rspec_junit_formatter'
  gem 'simplecov', '~> 0.22'
  gem 'simplecov-console', '~> 0.9'
  gem 'inspec', '~> 7.0'
end

group :docs do
  gem 'yard'
  gem 'redcarpet'
end