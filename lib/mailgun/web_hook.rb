# frozen_string_literal: true

module Mailgun
  module WebHook
  end
end

require 'mailgun/web_hook/authenticator'
require 'mailgun/web_hook/event_decorator'
require 'mailgun/web_hook/message_decorator'
require 'mailgun/web_hook/processor'
