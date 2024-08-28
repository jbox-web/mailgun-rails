# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mailgun::WebHook::Processor do
  let(:params) { {} }
  let(:processor_class) { described_class }
  let(:processor) { processor_class.new(params) }

  describe '#run!' do
    context 'when handler methods are present' do
      let(:params) { load_mailgun_event(:clicked)[:'event-data'] }

      it 'passes event payload to the handler' do
        allow(processor).to receive(:handle_clicked)
        processor.run!
        expect(processor).to have_received(:handle_clicked)
      end
    end

    context 'when no valid handler methods are present' do
      let(:params) { nil }

      it 'keeps calm and carries on' do
        expect { processor.run! }.to_not raise_error
      end
    end

    context 'with callback host' do
      let(:callback_host) { callback_host_class.new }
      let(:processor)     { processor_class.new(params, callback_host) }
      let(:params)        { load_mailgun_event(:clicked)[:'event-data'] }

      context 'with handler method as public' do
        let(:callback_host_class) do
          Class.new do
            def handle_clicked(_payload)
              'ok'
            end
          end
        end

        it 'passes event payload to the handler' do
          response = processor.run!
          expect(response).to eq 'ok'
        end
      end

      context 'with handler method as protected' do
        let(:callback_host_class) do
          Class.new do
            protected

              def handle_clicked(_payload)
                'ok'
              end
          end
        end

        it 'passes event payload to the handler' do
          response = processor.run!
          expect(response).to eq 'ok'
        end
      end

      context 'with handler method as private' do
        let(:callback_host_class) do
          Class.new do
            private

              def handle_clicked(_payload)
                'ok'
              end
          end
        end

        it 'passes event payload to the handler' do
          response = processor.run!
          expect(response).to eq 'ok'
        end
      end

      context 'with unhandled event' do
        let(:callback_host_class) { Class.new }

        context 'with default missing handler behaviour' do
          before { processor.on_unhandled_mailgun_events = :log }

          it 'logs an error' do
            logger = double
            allow(Rails).to receive(:logger).and_return(logger)
            allow(logger).to receive(:error)

            expect { processor.run! }.to_not raise_error
            expect(logger).to have_received(:error)
          end
        end

        context 'with ignore missing handler behaviour' do
          it 'keeps calm and carries on' do
            processor.on_unhandled_mailgun_events = :ignore

            expect { processor.run! }.to_not raise_error
          end
        end

        context 'with raise_exception missing handler behaviour' do
          it 'raises an error' do
            processor.on_unhandled_mailgun_events = :raise_exception
            expect { processor.run! }.to raise_error(MailgunRails::Errors::MissingEventHandler)
          end
        end
      end
    end
  end
end
