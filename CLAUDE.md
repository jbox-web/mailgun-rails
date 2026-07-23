# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this gem does

`mailgun-rails` is a Ruby gem that adds Mailgun webhook processing and event
decoration to a Rails app. It is a library (no Rails engine, no generators): a
host app mixes a concern into one of its controllers, and the gem authenticates,
parses and dispatches incoming Mailgun webhook events to per-event handler methods.

## Commands

Always use the project binstubs (they pin the Bundler context and gem versions):

- Run the full test suite: `bin/rspec`
- Run a single spec file: `bin/rspec spec/mailgun/web_hook/processor_spec.rb`
- Run a single example by line: `bin/rspec spec/mailgun/web_hook/processor_spec.rb:15`
- Lint: `bin/rubocop` (autocorrect: `bin/rubocop -a`)
- Default rake task (runs specs): `bin/rake`
- Guard (auto-run specs on change): `bin/guard`

Specs run with `--warnings` (see `.rspec`) and deprecation/experimental/performance
warnings are turned into failures via `spec_helper.rb`. Keep the code warning-clean.

## Architecture

Two namespaces with distinct roles — do not merge them:

- `MailgunRails` (`lib/mailgun_rails/`) — the **Rails-facing entry point**.
  `WebHookProcessor` is an `ActiveSupport::Concern` included in a host controller.
  It provides `show` (answers Mailgun's "are you there?" ping with `200`) and
  `create` (handles the webhook POST), skips CSRF verification, and runs
  `authenticate_mailgun_request!` before `create`. Class-level DSL configures the
  signing key (`mailgun_webhook_key`) and the unhandled-event policy
  (`log_unhandled_events!` / `ignore_unhandled_events!` / `unhandled_events_raise_exceptions!`,
  default `:raise_exception`).

- `Mailgun::WebHook` (`lib/mailgun/web_hook/`) — the **transport-agnostic core**,
  no Rails controller assumptions:
  - `Authenticator` — verifies the Mailgun HMAC-SHA256 signature
    (`timestamp` + `token` keyed by the API key) using a **constant-time compare**
    to prevent timing attacks. Never replace `secure_compare?` with `==`. It also
    rejects stale timestamps outside a freshness window (`DEFAULT_TOLERANCE`, 15
    min; configurable via `mailgun_webhook_tolerance`) to limit replay. The
    signature does not cover the event body — token deduplication is left to the
    host. `authentic?` fails closed (returns `false`, never raises) on missing
    params or nil/empty key.
  - `Processor` — `run!` decorates params then dispatches to a handler named
    `handle_<event_type>`. It looks first on the `callback_host` (the controller —
    matched even if the handler is `private`/`protected`, via `respond_to?(handler, true)`),
    then on itself; if none exists it applies the unhandled-event policy.
  - `MessageDecorator` — splits raw params into message headers (exposes
    `message_id`) and the event; delegates unknown methods to the `EventDecorator`.
  - `EventDecorator` — an `OpenStruct` over the event data; adds `delivery_status`
    to reach the hyphenated `delivery-status` key.

Event handler dispatch is convention-based: the method name is
`"handle_#{event_type}"` (downcased), where `event_type` is the `event` field of
Mailgun's `event-data` payload. Common types: `accepted, delivered, opened,
clicked, unsubscribed, complained, failed, rejected` (hard vs soft bounce both
arrive as `failed`, told apart via `severity`). See the doc comment in
`web_hook_processor.rb`.

## Loading

Autoloading is done by **Zeitwerk** (`lib/mailgun_rails.rb`). `lib/mailgun-rails.rb`
(hyphenated, the gem's `require` name) only requires `mailgun_rails` and is
explicitly ignored by both the Zeitwerk loader and RuboCop. Add new classes under
the existing namespace directories so Zeitwerk resolves them by path.

## Conventions

- Every Ruby file starts with `# frozen_string_literal: true`.
- `required_ruby_version >= 3.2.0`; runtime deps are kept minimal
  (`activesupport`, `ostruct`, `zeitwerk`) — don't pull Rails into the gemspec
  (Rails is a dev dependency only).
- Version lives in `lib/mailgun_rails/version.rb` (`MailgunRails::VERSION`).

## Testing notes

- `spec/support/test_controller.rb` is a hand-rolled controller mock (no real
  Rails controller harness — noted as a TODO in the file).
- Webhook payload fixtures live in `spec/fixtures/events/*.json`; load them with
  the `load_mailgun_event(:name)` helper from `spec_helper.rb`.
