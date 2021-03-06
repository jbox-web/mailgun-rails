# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailgunRails::WebHookProcessor do
  let(:processor_class) do
    Class.new(TestController) do
      include MailgunRails::WebHookProcessor

      mailgun_webhook_key nil
      on_unhandled_mailgun_events! nil
    end
  end

  let(:processor_instance) { processor_class.new }

  describe '#skip_before_action settings' do
    subject { processor_class.skip_before_action_settings }

    it 'includes verify_authenticity_token' do
      expect(subject).to eql([:verify_authenticity_token, { raise: false }])
    end
  end

  describe '#before_action settings' do
    subject { processor_class.before_action_settings }

    it 'includes authenticate_mailgun_request' do
      expect(subject).to eql([:authenticate_mailgun_request!, { only: [:create] }])
    end
  end

  describe '#mailgun_webhook_key' do
    context 'when not set' do
      it 'is empty' do
        expect(processor_class.mailgun_key).to eql(nil)
      end
    end

    context 'when mailgun_webhook_key set' do
      context 'with a single value' do
        it 'has the correct settings' do
          processor_class.mailgun_webhook_key 'key_a'

          expect(processor_class.mailgun_key).to eql('key_a')
        end
      end

      context 'with nil' do
        it 'has cached settings' do
          processor_class.mailgun_webhook_key 'key_a'
          processor_class.mailgun_webhook_key nil

          expect(processor_class.mailgun_key).to eql('key_a')
        end
      end
    end
  end

  describe '#show' do
    it 'should return head(:ok)' do
      expect(processor_instance).to receive(:head).with(:ok)
      processor_instance.show
    end
  end

  describe '#create' do
    before { processor_instance.params = {} }

    context 'when unhandled events is not configured' do
      it 'delegates the setting to the processor' do
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:on_unhandled_mailgun_events=).with(:raise_exception)
        processor_instance.create
      end
    end

    context 'when unhandled events set to log' do
      it 'delegates the setting to the processor' do
        processor_instance.class.log_unhandled_events!
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:on_unhandled_mailgun_events=).with(:log)
        processor_instance.create
      end
    end

    context 'when unhandled events set to raise exceptions' do
      it 'delegates the setting to the processor' do
        processor_instance.class.unhandled_events_raise_exceptions!
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:on_unhandled_mailgun_events=).with(:raise_exception)
        processor_instance.create
      end
    end

    context 'when unhandled events set to be ignored' do
      it 'delegates the setting to the processor' do
        processor_instance.class.ignore_unhandled_events!
        expect(processor_instance).to receive(:head).with(:ok)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:run!)
        expect_any_instance_of(Mailgun::WebHook::Processor).to receive(:on_unhandled_mailgun_events=).with(:ignore)
        processor_instance.create
      end
    end
  end

  describe '#authenticate_mailgun_request! (protected)' do
    let(:params) do
      ActionController::Parameters.new({
                                         'signature' => {
                                           'signature' => '4765ec02775fd594481ce162f479e7deac9edc5ee6cf30bc56e0a9e1125891b2',
                                           'timestamp' => '1534905663',
                                           'token' => '30e32e83019a5a439df5bbf47451b5b8a5ebe1940ab66dc34d'
                                         }
                                       })
    end

    before do
      processor_class.mailgun_webhook_key mailgun_webhook_key
      processor_instance.params = params
    end

    subject { processor_instance.send(:authenticate_mailgun_request!) }

    context 'with valid key' do
      let(:mailgun_webhook_key) { 'key-5c199000e06dc3e92c5a7db9a59f3c22' }

      it 'passes' do
        expect(subject).to eql(true)
      end
    end

    context 'with invalid key' do
      let(:mailgun_webhook_key) { 'bogative' }

      it 'calls head(:forbidden) and return false' do
        expect(processor_instance).to receive(:head).with(:forbidden, text: 'Mailgun signature did not match.')
        expect(subject).to eql(false)
      end
    end
  end
end
