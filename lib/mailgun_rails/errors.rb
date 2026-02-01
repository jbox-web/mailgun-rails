# frozen_string_literal: true

module MailgunRails
  module Errors
    class Base < StandardError
    end

    class MissingEventHandler < Base
    end
  end
end
