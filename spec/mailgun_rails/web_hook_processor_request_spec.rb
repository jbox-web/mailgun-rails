# frozen_string_literal: true

require 'spec_helper'

# End-to-end request specs driving the concern through a real ActionController
# (see spec/support/integration/*). These complement the unit specs in
# web_hook_processor_spec.rb: they exercise the full Rails stack — the
# `authenticate_mailgun_request!` before_action, real ActionController::Parameters
# and real `head` responses — which the hand-rolled TestController mock cannot.
RSpec.describe 'MailgunRails::WebHookProcessor (request)', type: :request do
  include MailgunRailsIntegration::Helpers

  # Known-good triple (matches web_hook_processor_spec.rb and the fixtures).
  let(:signature) do
    {
      'signature' => '4765ec02775fd594481ce162f479e7deac9edc5ee6cf30bc56e0a9e1125891b2',
      'timestamp' => '1534905663',
      'token' => '30e32e83019a5a439df5bbf47451b5b8a5ebe1940ab66dc34d',
    }
  end

  let(:event_data) { { 'event' => 'delivered', 'id' => 'evt-123' } }

  before do
    # Freeze the clock just after the signed timestamp so the freshness check passes.
    allow(Time).to receive(:now).and_return(Time.at(1_534_905_663 + 60).utc)
    MailgunWebhookTestController.reset!
  end

  describe 'GET (Mailgun "are you there?" ping)' do
    it 'answers 200 without authentication' do
      session = new_session
      session.get '/mailgun/webhook'

      expect(session.response.status).to eq(200)
    end
  end

  describe 'POST with a valid signature' do
    it 'authenticates, dispatches to the handler and answers 200' do
      session = new_session
      session.post '/mailgun/webhook', params: { signature: signature, 'event-data' => event_data }

      expect(session.response.status).to eq(200)
      expect(MailgunWebhookTestController.handled_events.size).to eq(1)
      expect(MailgunWebhookTestController.handled_events.first.event_type).to eq('delivered')
    end
  end

  describe 'POST with an invalid signature' do
    it 'is rejected by the before_action with 403 and never reaches the handler' do
      session = new_session
      session.post '/mailgun/webhook',
                   params: { signature: signature.merge('signature' => '0' * 64), 'event-data' => event_data }

      expect(session.response.status).to eq(403)
      expect(MailgunWebhookTestController.handled_events).to be_empty
    end
  end
end
