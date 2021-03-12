# frozen_string_literal: true

require 'yaml'
require 'rails'
require 'simplecov'

# Start SimpleCov
SimpleCov.start do
  add_filter 'spec/'
end

# Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end

# Load lib
require 'mailgun-rails'

# Load test helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

def fixture_path(name)
  File.expand_path("fixtures/#{name}", __dir__)
end

def load_mailgun_event(event)
  JSON.parse(File.read(fixture_path("events/#{event}.json"))).with_indifferent_access
end
