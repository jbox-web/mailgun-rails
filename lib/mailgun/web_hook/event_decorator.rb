# frozen_string_literal: true

module Mailgun
  module WebHook
    class EventDecorator < OpenStruct # rubocop:disable Style/OpenStructUse

      def delivery_status
        self['delivery-status']
      end
    end
  end
end
