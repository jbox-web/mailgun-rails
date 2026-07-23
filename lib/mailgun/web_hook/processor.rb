# frozen_string_literal: true

module Mailgun
  module WebHook
    class Processor

      attr_accessor :params, :callback_host, :mailgun_events, :on_unhandled_mailgun_events
      attr_writer :logger

      # Command initialise the processor with +params+ Hash.
      # +params+ is expected to contain an array of mailgun_events.
      # +callback_host+ is a handle to the controller making the request.
      #
      def initialize(params = {}, callback_host = nil)
        self.params = params || {}
        self.callback_host = callback_host
      end


      def run!
        process_event Mailgun::WebHook::MessageDecorator.new(params)
      end


      private


        def process_event(event_payload)
          handler = "handle_#{event_payload.event_type}".downcase.to_sym

          if callback_host.respond_to?(handler, true)
            callback_host.send(handler, event_payload)
          elsif respond_to?(handler, true)
            send(handler, event_payload)
          else
            handle_unhandled_event(handler, event_payload)
          end
        end


        def handle_unhandled_event(handler, event_payload)
          error_message = unhandled_event_message(handler, event_payload.event_type)

          case on_unhandled_mailgun_events
          when :ignore
            # NOP
          when :raise_exception
            raise MailgunRails::Errors::MissingEventHandler, error_message
          when :log
            logger.error error_message
          end
        end


        def unhandled_event_message(handler, event_type)
          if event_type.blank?
            'Received a Mailgun webhook payload with no event type'
          else
            "Expected handler method `#{handler}` for event type `#{event_type}`"
          end
        end


        # Decoupled from Rails so the core stays transport-agnostic: use the Rails
        # logger when running inside a Rails app, otherwise fall back to $stderr.
        def logger
          @logger ||= if defined?(Rails)
                        Rails.logger
                      else
                        # :nocov: — the test suite always loads Rails (rails/all),
                        # so this dependency-free fallback is unreachable here.
                        require 'logger'
                        Logger.new($stderr)
                        # :nocov:
                      end
        end

    end
  end
end
