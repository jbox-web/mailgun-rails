# Mailgun Rails

[![GitHub license](https://img.shields.io/github/license/jbox-web/mailgun-rails.svg)](https://github.com/jbox-web/mailgun-rails/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/jbox-web/mailgun-rails.svg)](https://github.com/jbox-web/mailgun-rails/releases/latest)
[![CI](https://github.com/jbox-web/mailgun-rails/workflows/CI/badge.svg)](https://github.com/jbox-web/mailgun-rails/actions)
[![Code Climate](https://codeclimate.com/github/jbox-web/mailgun-rails/badges/gpa.svg)](https://codeclimate.com/github/jbox-web/mailgun-rails)
[![Test Coverage](https://codeclimate.com/github/jbox-web/mailgun-rails/badges/coverage.svg)](https://codeclimate.com/github/jbox-web/mailgun-rails/coverage)

Mailgun Rails provides webhook processing and event decoration to make using Mailgun with Rails much easier.

## Installation

Put this in your `Gemfile` :

```ruby
git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gem 'mailgun-rails', github: 'jbox-web/mailgun-rails', tag: '1.0.0'
```

then run `bundle install`.
