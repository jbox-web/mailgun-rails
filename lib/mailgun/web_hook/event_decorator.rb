module Mailgun
  module WebHook
    class EventDecorator < Hash

      def message_id
        strip_character(self['Message-Id'] || self['message-id'])
      end


      def event_type
        self['event']
      end


      def recipient
        self['recipient'].try(:downcase)
      end


      def domain
        self['domain']
      end


      def headers
        data = {}
        headers = JSON.parse(self['message-headers']) rescue []
        headers.each do |l|
          data[l.first.downcase] = l.last
        end
        data
      end


      def subject
        headers['subject']
      end


      def from
        headers['from']
      end


      def to
        headers['to']
      end


      def sender
        headers['sender']
      end


      private


        def strip_character(string)
          return '' if string.nil?
          string = string[1..-1] if string.start_with?('<')
          string = string.chop   if string.end_with?('>')
          string
        end

    end
  end
end
