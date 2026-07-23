# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailgun::WebHook::MessageDecorator do
  describe '#message_id' do
    context 'when message headers are present' do
      subject(:decorator) do
        described_class.new({ message: { headers: { 'message-id' => 'abc@example.net' } }, event: 'delivered' })
      end

      it 'returns the message id' do
        expect(decorator.message_id).to eq('abc@example.net')
      end
    end

    context 'when message headers are absent' do
      subject(:decorator) { described_class.new({ event: 'clicked' }) }

      it 'returns nil instead of raising' do
        expect { decorator.message_id }.to_not raise_error
        expect(decorator.message_id).to be_nil
      end
    end
  end

  describe '#event_type' do
    subject(:decorator) { described_class.new({ event: 'clicked' }) }

    it 'exposes the event name' do
      expect(decorator.event_type).to eq('clicked')
    end
  end

  describe 'delegation to the event' do
    subject(:decorator) { described_class.new({ event: 'clicked', recipient: 'alice@example.com' }) }

    it 'delegates unknown readers to the event' do
      expect(decorator.recipient).to eq('alice@example.com')
    end

    it 'answers respond_to? for delegated readers' do
      expect(decorator).to respond_to(:recipient)
    end
  end
end
