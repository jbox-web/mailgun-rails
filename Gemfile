# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'guard-rspec'
gem 'rails', '>= 6.0'
gem 'rake'
gem 'rspec'
gem 'rubocop'
gem 'rubocop-performance'
gem 'rubocop-rails'
gem 'rubocop-rake'
gem 'rubocop-rspec'
gem 'simplecov'

# Fix:
# warning: ostruct was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0
# Add ostruct to your Gemfile or gemspec.
#
# warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0
# Add logger to your Gemfile or gemspec.
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4.0')
  gem 'logger'
  gem 'ostruct'
end
