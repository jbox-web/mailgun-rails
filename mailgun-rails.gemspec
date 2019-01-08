# frozen_string_literal: true

require_relative 'lib/mailgun_rails/version'

Gem::Specification.new do |s|
  s.name        = 'mailgun-rails'
  s.version     = MailgunRails::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nicolas Rodriguez']
  s.email       = ['nrodriguez@jbox-web.com']
  s.homepage    = 'https://github.com/jbox-web/mailgun-rails'
  s.summary     = %q{Rails integration for Mailgun}
  s.description = %q{Provides webhook processing and event decoration to make using Mailgun with Rails just that much easier}
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'activesupport', '>= 4.2'
end
