module MailgunRails
  module Errors
    Base                = Class.new(StandardError)
    MissingEventHandler = Class.new(Base)
  end
end
