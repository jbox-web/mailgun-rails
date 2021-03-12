# frozen_string_literal: true

module Mailgun
  module WebHook
    class MessageDecorator

      attr_reader :event

      def initialize(params = {})
        @headers = params.fetch(:message).fetch(:headers)
        @event   = Mailgun::WebHook::EventDecorator.new(params.except(:message))
      end

      def message_id
        @headers.fetch('message-id')
      end

      def event_type
        event.event
      end

      def method_missing(method, *args)
        event.send(method, *args)
      end

    end
  end
end
