module Mailgun
  module WebHook
    class Authenticator

      attr_reader :api_key
      attr_reader :event_params


      def initialize(api_key, event_params = {})
        @api_key      = api_key
        @event_params = event_params.to_hash
      end


      def authentic?
        actual_signature == expected_signature
      rescue => e
        Rails.logger.error e.message
        false
      end


      private


        def actual_signature
          event_params.fetch('signature')
        end


        def expected_signature
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, api_key, "#{timestamp}#{token}")
        end


        def timestamp
          event_params.fetch('timestamp')
        end


        def token
          event_params.fetch('token')
        end

    end
  end
end
