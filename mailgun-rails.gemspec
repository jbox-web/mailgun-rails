# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mailgun_rails/version'

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

  s.add_dependency 'activesupport', '>= 4.0.0', '< 5.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
