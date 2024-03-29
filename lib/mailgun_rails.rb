# frozen_string_literal: true

require 'json'
require 'ostruct'
require 'openssl'
require 'active_support'
require 'active_support/core_ext'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect 'mailgun-rails' => 'MailgunRails'
loader.setup

module MailgunRails
end
