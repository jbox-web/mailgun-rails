# frozen_string_literal: true

class TestController
  # Mock some controller behaviour
  # TODO: we should probably start using a real controller harness for testing

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
