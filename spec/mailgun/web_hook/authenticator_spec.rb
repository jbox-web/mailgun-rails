# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailgun::WebHook::Authenticator do
  subject(:authenticator) { described_class.new(api_key, params, now: now) }

  # Known-good triple (matches spec/mailgun_rails/web_hook_processor_spec.rb).
  let(:api_key)   { 'key-5c199000e06dc3e92c5a7db9a59f3c22' }
  let(:timestamp) { '1534905663' }
  let(:signature) { '4765ec02775fd594481ce162f479e7deac9edc5ee6cf30bc56e0a9e1125891b2' }

  let(:params) do
    {
      'signature' => signature,
      'timestamp' => timestamp,
      'token' => '30e32e83019a5a439df5bbf47451b5b8a5ebe1940ab66dc34d',
    }
  end

  # Epoch just after the signed timestamp so the freshness check passes.
  let(:now) { timestamp.to_i + 60 }

  describe '#authentic?' do
    context 'with a valid signature within the tolerance window' do
      it 'is true' do
        expect(authenticator.authentic?).to be(true)
      end
    end

    context 'with an invalid signature' do
      let(:signature) { '0' * 64 }

      it 'is false' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when all signature params are missing' do
      let(:params) { {} }

      it 'is false and does not raise' do
        expect { authenticator.authentic? }.to_not raise_error
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when a single signature component is missing' do
      let(:params) { { 'signature' => signature, 'timestamp' => timestamp } }

      it 'is false' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when event_params is nil' do
      let(:params) { nil }

      it 'is false and does not raise' do
        expect { authenticator.authentic? }.to_not raise_error
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when the signature length differs from the expected digest' do
      let(:signature) { 'deadbeef' }

      it 'is false (constant-time compare bails on size mismatch)' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when the api key is nil' do
      let(:api_key) { nil }

      it 'is false and does not raise' do
        expect { authenticator.authentic? }.to_not raise_error
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when the api key is empty' do
      let(:api_key) { '' }

      it 'is false' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when the timestamp is outside the tolerance window' do
      let(:now) { timestamp.to_i + described_class::DEFAULT_TOLERANCE + 60 }

      it 'is false (stale / replay)' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'when the timestamp is not numeric' do
      let(:timestamp) { 'not-a-timestamp' }

      it 'is false' do
        expect(authenticator.authentic?).to be(false)
      end
    end

    context 'with freshness disabled (tolerance: nil)' do
      subject(:authenticator) { described_class.new(api_key, params, tolerance: nil, now: now) }

      let(:now) { timestamp.to_i + (10 * 365 * 24 * 3600) }

      it 'ignores freshness and only validates the signature' do
        expect(authenticator.authentic?).to be(true)
      end
    end
  end
end
