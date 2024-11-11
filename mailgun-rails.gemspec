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

  s.required_ruby_version = '>= 3.1.0'

  s.files = Dir['README.md', 'LICENSE', 'lib/**/*.rb']

  s.add_dependency 'activesupport', '>= 7.0'
  s.add_dependency 'ostruct'
  s.add_dependency 'zeitwerk', '~> 2.6.0'
end
