# frozen_string_literal: true

module Mailgun
  module WebHook
    class Authenticator

      attr_reader :api_key, :event_params


      def initialize(api_key, event_params = {})
        @api_key      = api_key
        @event_params = event_params&.to_hash || {}
      end


      def authentic?
        secure_compare(actual_signature, expected_signature)
      end


      private


        def actual_signature
          event_params.fetch('signature')
        end


        def expected_signature
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA256'), api_key, "#{timestamp}#{token}")
        end


        def timestamp
          event_params.fetch('timestamp')
        end


        def token
          event_params.fetch('token')
        end


        # From Devise : https://github.com/plataformatec/devise/blob/master/lib/devise.rb#L485
        # constant-time comparison algorithm to prevent timing attacks
        # rubocop:disable Naming/MethodParameterName, Layout/CommentIndentation
        def secure_compare(a, b)
          return false if a.blank? || b.blank? || a.bytesize != b.bytesize

          l = a.unpack "C#{a.bytesize}"

          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res.zero?
        end
        # rubocop:enable Naming/MethodParameterName, Layout/CommentIndentation

    end
  end
end
