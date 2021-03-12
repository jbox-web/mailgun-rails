# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailgun::WebHook::Processor do
  let(:params) { {} }
  let(:processor_class) { Mailgun::WebHook::Processor }
  let(:processor) { processor_class.new(params) }

  describe '#run!' do
    context 'when handler methods are present' do
      let(:params) { load_mailgun_event(:clicked)[:'event-data'] }

      it 'passes event payload to the handler' do
        expect(processor).to receive(:handle_clicked)
        processor.run!
      end
    end

    context 'but no valid handler methods are present' do
      let(:params) { nil }
      it 'keeps calm and carries on' do
        processor.run!
      end
    end

    context 'with callback host' do
      let(:callback_host) { callback_host_class.new }
      let(:processor)     { processor_class.new(params, callback_host) }
      let(:params)        { load_mailgun_event(:clicked)[:'event-data'] }

      context 'with handler method as public' do
        let(:callback_host_class) do
          Class.new do
            def handle_clicked
              'ok'
            end
          end
        end

        it 'passes event payload to the handler' do
          expect(callback_host).to receive(:handle_clicked).and_return('ok')
          processor.run!
        end
      end

      context 'with handler method as protected' do
        let(:callback_host_class) do
          Class.new do
            protected

              def handle_clicked
                'ok'
              end
          end
        end

        it 'passes event payload to the handler' do
          expect(callback_host).to receive(:handle_clicked).and_return('ok')
          processor.run!
        end
      end

      context 'with handler method as private' do
        let(:callback_host_class) do
          Class.new do
            private

              def handle_clicked
                'ok'
              end
          end
        end

        it 'passes event payload to the handler' do
          expect(callback_host).to receive(:handle_clicked).and_return('ok')
          processor.run!
        end
      end

      context 'with unhandled event' do
        let(:callback_host_class) { Class.new }

        context 'and default missing handler behaviour' do
          it 'logs an error' do
            processor.on_unhandled_mailgun_events = :log
            logger = double
            expect(logger).to receive(:error)
            expect(Rails).to receive(:logger).and_return(logger)

            expect do
              processor.run!
            end.to_not raise_error
          end
        end

        context 'and ignore missing handler behaviour' do
          it 'keeps calm and carries on' do
            processor.on_unhandled_mailgun_events = :ignore

            expect do
              processor.run!
            end.to_not raise_error
          end
        end

        context 'and raise_exception missing handler behaviour' do
          it 'raises an error' do
            processor.on_unhandled_mailgun_events = :raise_exception
            expect do
              processor.run!
            end.to raise_error(MailgunRails::Errors::MissingEventHandler)
          end
        end
      end
    end
  end
end
