# frozen_string_literal: true

module Mailgun
  module WebHook
    class Processor

      attr_accessor :params, :callback_host, :mailgun_events, :on_unhandled_mailgun_events

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


        # rubocop:disable Metrics/MethodLength, Layout/CommentIndentation
        def process_event(event_payload)
          handler = "handle_#{event_payload.event_type}".downcase.to_sym

          if callback_host.respond_to?(handler, true)
            callback_host.send(handler, event_payload)
          elsif respond_to?(handler)
            send(handler, event_payload)
          else
            error_message = "Expected handler method `#{handler}` for event type `#{event_payload.event_type}`"

            case on_unhandled_mailgun_events
            when :ignore
              # NOP
            when :raise_exception
              raise MailgunRails::Errors::MissingEventHandler, error_message
            else
              begin
                Rails.logger.error error_message
              rescue StandardError
                nil
              end
            end
          end
        end
        # rubocop:enable Metrics/MethodLength, Layout/CommentIndentation

    end
  end
end
