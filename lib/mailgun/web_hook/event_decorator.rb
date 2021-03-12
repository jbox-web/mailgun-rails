# frozen_string_literal: true

module Mailgun
  module WebHook
    class EventDecorator < OpenStruct

      def delivery_status
        self['delivery-status']
      end
    end
  end
end
