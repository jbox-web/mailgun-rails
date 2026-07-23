# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailgun::WebHook::EventDecorator do
  describe '#delivery_status' do
    subject(:event) { described_class.new({ 'delivery-status' => { 'code' => 250 } }) }

    it 'reaches the hyphenated delivery-status key' do
      expect(event.delivery_status).to eq({ 'code' => 250 })
    end
  end

  describe 'attribute access' do
    subject(:event) { described_class.new({ 'event' => 'delivered' }) }

    it 'exposes event data as readers' do
      expect(event.event).to eq('delivered')
    end
  end
end
