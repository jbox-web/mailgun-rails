# frozen_string_literal: true

class TestController
  # Mock some controller behaviour, for unit-testing the concern's methods in
  # isolation. A real controller harness now lives alongside these in
  # spec/support/integration_app.rb (driven by the request specs); this mock is
  # kept for the fast, dependency-free unit specs.

  class << self
    attr_reader :skip_before_action_settings, :before_action_settings

    def skip_before_action(*args)
      @skip_before_action_settings = args
    end

    def before_action(*args)
      @before_action_settings = args
    end
  end

  attr_accessor :params, :request

  def head(*args); end
end
