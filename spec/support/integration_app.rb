# frozen_string_literal: true

# Minimal, real Rails harness used by the request specs
# (spec/mailgun_rails/web_hook_processor_request_spec.rb) to drive the
# WebHookProcessor concern through an actual ActionController — the
# before_action authentication, real ActionController::Parameters and real
# `head` responses that the TestController mock cannot reproduce.
#
# It uses a bare ActionDispatch::Routing::RouteSet as the Rack app rather than a
# full Rails::Application: the suite already requires 'rails/all', so a real
# application would boot the ActiveRecord railtie and demand a database config we
# have no use for. The route set dispatches straight to the controller.
#
# This is deliberately kept alongside the unit specs rather than replacing the
# mock: the mock still tests the concern's methods in isolation.

require 'action_controller/railtie'

# A real controller including the concern under test, with one handler so we can
# assert end-to-end dispatch. There is no host ApplicationController in a gem, so
# it subclasses ActionController::Base directly.
class MailgunWebhookTestController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include MailgunRails::WebHookProcessor

  mailgun_webhook_key 'key-5c199000e06dc3e92c5a7db9a59f3c22'

  # Records the events dispatched to it so specs can assert on them.
  @handled_events = []

  class << self
    attr_accessor :handled_events

    def reset!
      @handled_events = []
    end
  end

  def handle_delivered(event_payload)
    self.class.handled_events << event_payload
  end
end

module MailgunRailsIntegration
  # A routes-only Rack app exposing the two webhook endpoints.
  ROUTES = ActionDispatch::Routing::RouteSet.new.tap do |set|
    set.draw do
      get  'mailgun/webhook' => 'mailgun_webhook_test#show'
      post 'mailgun/webhook' => 'mailgun_webhook_test#create'
    end
  end

  module Helpers
    def new_session
      ActionDispatch::Integration::Session.new(MailgunRailsIntegration::ROUTES)
    end
  end
end
