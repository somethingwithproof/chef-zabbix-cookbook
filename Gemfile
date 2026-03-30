source 'https://rubygems.org'

gem 'chef', '~> 19.2'
gem 'chef-cli', '~> 6.1'
gem 'berkshelf', '>= 8.0'

# Pin psych to avoid compilation issues with Ruby 3.2+
gem 'psych', '< 6'

group :development do
  gem 'chefspec', '~> 9.3'
  gem 'cookstyle', '~> 8.6'
  # Use inspec-core (not inspec) to avoid commercial chef-licensing requirement in InSpec 7+
  gem 'inspec-core', '~> 7.0'
  gem 'kitchen-dokken', '~> 2.22'
  # 3.1+ supports test-kitchen 4.x and inspec-core 6.x/7.x
  gem 'kitchen-inspec', '~> 3.1'
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
end

group :docs do
  gem 'yard'
  gem 'redcarpet'
end
