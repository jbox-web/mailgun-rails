# frozen_string_literal: true

module Mailgun
  module WebHook
    class MessageDecorator

      attr_reader :event

      def initialize(params = {})
        @headers = params.fetch(:message, {}).fetch(:headers, {})
        @event   = Mailgun::WebHook::EventDecorator.new(params.except(:message))
      end

      def message_id
        @headers.fetch('message-id', nil)
      end

      def event_type
        event.event
      end

      def respond_to_missing?(method, include_private = false)
        event.respond_to?(method, include_private)
      end

      def method_missing(method, *)
        event.send(method, *)
      end

    end
  end
end
