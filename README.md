# Mailgun Rails

[![GitHub license](https://img.shields.io/github/license/jbox-web/mailgun-rails.svg)](https://github.com/jbox-web/mailgun-rails/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/jbox-web/mailgun-rails.svg)](https://github.com/jbox-web/mailgun-rails/releases/latest)
[![CI](https://github.com/jbox-web/mailgun-rails/workflows/CI/badge.svg)](https://github.com/jbox-web/mailgun-rails/actions)

Mailgun Rails provides webhook processing and event decoration to make using Mailgun with Rails much easier.

## Installation

Put this in your `Gemfile` :

```ruby
git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gem 'mailgun-rails', github: 'jbox-web/mailgun-rails', tag: '1.0.0'
```

then run `bundle install`.

## Usage

Include the `MailgunRails::WebHookProcessor` concern in a controller, point a
`GET :show` and a `POST :create` route at it, configure your Mailgun HTTP webhook
signing key, and define a `handle_<event>` method per event type you care about.

```ruby
# config/routes.rb
resource :mailgun_webhook, only: %i[show create], controller: 'mailgun_webhooks'
```

```ruby
# app/controllers/mailgun_webhooks_controller.rb
class MailgunWebhooksController < ApplicationController
  include MailgunRails::WebHookProcessor

  # Your Mailgun "HTTP webhook signing key" (Mailgun dashboard → Settings → Webhooks).
  # Store it in credentials/ENV, never in source.
  mailgun_webhook_key Rails.application.credentials.dig(:mailgun, :webhook_signing_key)

  # Handler name is `handle_<event>`, where <event> is the (downcased) `event`
  # field of Mailgun's `event-data` payload.
  def handle_delivered(event)
    # event.recipient, event.message_id, event.delivery_status, ...
  end

  def handle_opened(event)
    # ...
  end

  # Hard and soft bounces both arrive as `failed`; tell them apart via severity.
  def handle_failed(event)
    if event.severity == 'permanent'
      # hard bounce
    else
      # soft bounce / temporary failure
    end
  end
end
```

Common event types: `accepted`, `delivered`, `opened`, `clicked`, `unsubscribed`,
`complained`, `failed`, `rejected`.

### Authentication & replay protection

Every `POST :create` is rejected with `403 Forbidden` unless it carries a valid
Mailgun signature (constant-time HMAC-SHA256 over `timestamp` + `token`, keyed by
your signing key). Requests whose signed timestamp is older than a tolerance
window (default 15 minutes) are also rejected, to limit replay of captured
requests. Tune the window per controller:

```ruby
mailgun_webhook_tolerance 5.minutes.to_i
```

The signature covers only `timestamp` + `token`, not the event body. If you need
stronger replay protection, additionally deduplicate `token` in your own store.

### Unhandled events

When a webhook arrives for which no `handle_<event>` method is defined, the policy
is (default) to raise `MailgunRails::Errors::MissingEventHandler`. Override it at
the class level:

```ruby
log_unhandled_events!               # log the error and return 200
ignore_unhandled_events!            # silently return 200
unhandled_events_raise_exceptions!  # raise (default)
```

Under the `:log` policy the error is written to `Rails.logger` by default. Provide
your own logger (any object responding to `#error`) with:

```ruby
mailgun_logger Rails.logger.tagged('mailgun')
```
