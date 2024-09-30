# frozen_string_literal: true

# require ruby dependencies
require 'json'
require 'ostruct'
require 'openssl'

# require external dependencies
require 'active_support'
require 'active_support/core_ext'
require 'zeitwerk'

# load zeitwerk
Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap do |loader|
  loader.ignore("#{__dir__}/mailgun-rails.rb")
  loader.setup
end

module MailgunRails
end
