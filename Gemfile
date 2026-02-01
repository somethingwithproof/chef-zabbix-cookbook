source 'https://rubygems.org'

gem 'chef', '~> 18.0'
gem 'berkshelf', '>= 8.0'

group :development do
  gem 'chefspec', '~> 9.3'
  gem 'cookstyle', '~> 8.1'
  gem 'kitchen-dokken', '~> 2.20'
  gem 'kitchen-inspec'
  gem 'test-kitchen', '>= 3.0'
  gem 'rake', '~> 13.0'
  # Required by postgresql cookbook dependency
  gem 'deepsort', '~> 0.5.0'
  gem 'inifile', '~> 3.0'
end

group :test do
  # Pin RSpec to version compatible with ChefSpec 9.3
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-expectations', '~> 3.12.0'
  gem 'rspec_junit_formatter'
  gem 'simplecov', '~> 0.22'
  gem 'simplecov-console', '~> 0.9'
  # Required by postgresql cookbook
  gem 'deepsort', '~> 0.5.0'
  gem 'inifile', '~> 3.0'
end

group :docs do
  gem 'yard'
  gem 'redcarpet'
end
