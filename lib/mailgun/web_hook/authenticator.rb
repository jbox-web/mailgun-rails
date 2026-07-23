# frozen_string_literal: true

module Mailgun
  module WebHook
    class Authenticator

      # Maximum accepted age (in seconds) of a signed webhook timestamp. Requests
      # whose timestamp is further than this from the current time are rejected.
      #
      # The Mailgun signature only covers `timestamp` + `token` (never the event
      # body), so a captured triple could otherwise be replayed forever. Freshness
      # is the primary, dependency-free replay defence; callers needing stronger
      # guarantees should additionally deduplicate `token` in their own store.
      DEFAULT_TOLERANCE = 15 * 60

      attr_reader :api_key, :event_params, :tolerance


      # +tolerance+ is the freshness window in seconds (nil disables the check).
      # +now+ injects the current time (a Time) for deterministic testing.
      def initialize(api_key, event_params = {}, tolerance: DEFAULT_TOLERANCE, now: nil)
        @api_key      = api_key
        @event_params = event_params&.to_hash || {}
        @tolerance    = tolerance
        @now          = now
      end


      def authentic?
        return false if api_key.to_s.empty?
        return false unless signature_present?
        return false unless recent?

        secure_compare?(actual_signature, expected_signature)
      end


      private


        def signature_present?
          %w[signature timestamp token].all? { |key| event_params[key].present? }
        end


        def recent?
          return true if tolerance.nil?

          signed_at = Float(timestamp, exception: false)
          return false if signed_at.nil?

          (current_time - signed_at).abs <= tolerance
        end


        def current_time
          return @now.to_i if @now

          Time.now.to_i
        end


        def actual_signature
          event_params['signature']
        end


        def expected_signature
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA256'), api_key, "#{timestamp}#{token}")
        end


        def timestamp
          event_params['timestamp']
        end


        def token
          event_params['token']
        end


        # From Devise : https://github.com/plataformatec/devise/blob/master/lib/devise.rb#L485
        # constant-time comparison algorithm to prevent timing attacks
        # rubocop:disable Naming/MethodParameterName, Layout/CommentIndentation
        def secure_compare?(a, b)
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
