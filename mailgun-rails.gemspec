# frozen_string_literal: true

require_relative 'lib/mailgun_rails/version'

Gem::Specification.new do |s|
  s.name        = 'mailgun-rails'
  s.version     = MailgunRails::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nicolas Rodriguez']
  s.email       = ['nico@nicoladmin.fr']
  s.homepage    = 'https://github.com/jbox-web/mailgun-rails'
  s.summary     = 'Rails integration for Mailgun'
  s.description = 'Provides webhook processing and event decoration to make using Mailgun with Rails much easier'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'activesupport', '>= 6.0'
  s.add_runtime_dependency 'zeitwerk'

  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rails', '>= 6.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
    s.add_development_dependency "logger"
    s.add_development_dependency "ostruct"
  end
end
