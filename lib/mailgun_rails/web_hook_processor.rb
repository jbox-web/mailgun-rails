# frozen_string_literal: true

# WebHookProcessor is a module that mixes in Mailgun web hook processing support
# to a controller in your application.
#
# The controller is expected to be a singlular resource controller.
# WebHookProcessor provides the :show and :create method implementation.
#
# 1. Create a controller that includes Mailgun::Rails::WebHookProcessor
# 2. Direct a GET :show and POST :create route to the controller
# 3. Define handlers for each of the event types you want to handle
#
# e.g. in routes.rb:
#
#   resource :webhook, :controller => 'webhook', :only => [:show,:create]
#
# e.g. a Webhook controller:
#
#   class WebhookController < ApplicationController
#     include MailgunRails::WebHookProcessor
#
#     # Command: handle each 'inbound' +event_payload+ from Mailgun
#     def handle_inbound(event_payload)
#       # do some stuff
#     end
#
#     # Define other handlers for each event type required.
#     # Possible event types: inbound, send, hard_bounce, soft_bounce, open, click, spam, unsub, or reject
#     # def handle_<event_type>(event_payload)
#     #   # do some stuff
#     # end
#
#   end
#
module MailgunRails
  module WebHookProcessor
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token, raise: false
      before_action      :authenticate_mailgun_request!, only: [:create]
    end

    module ClassMethods

      def mailgun_webhook_key(key)
        @mailgun_webhook_key ||= key
      end


      def mailgun_key
        @mailgun_webhook_key
      end


      def on_unhandled_mailgun_events!(new_setting = nil)
        @on_unhandled_mailgun_events = new_setting unless new_setting.nil?
        @on_unhandled_mailgun_events ||= :log
        @on_unhandled_mailgun_events
      end


      def ignore_unhandled_events!
        on_unhandled_mailgun_events! :ignore
      end


      def unhandled_events_raise_exceptions!
        on_unhandled_mailgun_events! :raise_exception
      end

    end


    # Handles controller :show action (corresponds to a Mailgun "are you there?" test ping).
    # Returns 200 and does nothing else.
    def show
      block_given? ? yield : head(:ok)
    end


    # Handles controller :create action (corresponds to a POST from Mailgun).
    def create
      processor = Mailgun::WebHook::Processor.new(mailgun_params, self)
      processor.on_unhandled_mailgun_events = self.class.on_unhandled_mailgun_events!
      processor.run!
      block_given? ? yield : head(:ok)
    end


    private


      def authenticate_mailgun_request!
        if Mailgun::WebHook::Authenticator.new(self.class.mailgun_key, mailgun_auth_params[:signature]).authentic?
          true
        else
          head(:forbidden, text: 'Mailgun signature did not match.')
          false
        end
      end


      def mailgun_auth_params
        params.permit(signature: %i[signature timestamp token])
      end


      def mailgun_params
        params[:'event-data'].to_unsafe_h
      end

  end
end
