# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# Dev libs
gem 'rails', '>= 6.0'
gem 'rake'
gem 'rspec'
gem 'simplecov'

# Dev tools / linter
gem 'guard-rspec',         require: false
gem 'rubocop',             require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails',       require: false
gem 'rubocop-rake',        require: false
gem 'rubocop-rspec',       require: false

# Fix:
# warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0
# Add logger to your Gemfile or gemspec.
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4.0') # rubocop:disable Style/IfUnlessModifier
  gem 'logger'
end
