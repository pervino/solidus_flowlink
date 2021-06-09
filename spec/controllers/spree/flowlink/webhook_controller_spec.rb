require 'spec_helper'

RSpec.describe Spree::Flowlink::WebhookController do
  include Capybara::RSpecMatchers

  let(:message) { ::Flowlink::Samples::Order.request }

  describe '#consume' do
    context 'when authenticating a user' do
      subject do
        post(
          'consume',
          body: message.to_json,
          format: :json,
          params: { path: 'my_custom' }
        )
      end

      context 'with authorization token' do
        before do
          request.headers['Authorization'] = "Bearer #{user.spree_api_key}"
        end

        context 'with a user without proper permissions' do
          let(:user) { create(:user, :with_api_key) }
          it 'is not authorized' do
            subject
            expect(response.code).to eq('401')
          end
        end

        context 'with a user with proper permissions' do
          let(:user) { create(:admin_user, :with_api_key) }

          it 'is authorized' do
            subject
            expect(response).to be_success
          end
        end
      end

      context 'with whitelisted ip address' do
        context 'with non-whitelisted ip address' do
          it 'returns 401 status', :aggregrate_failures do
            subject
            expect(response.code).to eql "401"
            response_json = ::JSON.parse(response.body)
            expect(response_json["request_id"]).to_not be_nil
            expect(response_json["summary"]).to include "Unauthorized!"
          end
        end

        context 'with whitelisted ip address' do
          context 'with the correct auth' do
            before do
              request.remote_ip = '34.75.173.205'
            end

            it 'is authorized' do
              subject
              expect(response).to be_success
            end
          end
        end
      end
    end

    context 'with the correct auth' do
      before do
        request.remote_ip = '34.75.173.205'
      end

      context 'and an existing handler for the webhook' do
        it 'will process the webhook handler' do
          post(
            'consume',
            body: message.to_json,
            format: :json,
            params: { path: 'my_custom' }
          )
          expect(response).to be_success
        end
      end

      context 'when an exception happens' do
        let(:web_request) do
          post(
            'consume',
            body: message.to_json,
            format: :json,
            params: { path: invalid_path }
          )
        end

        let(:invalid_path) { 'upblate_order' }

        it 'will return response with the exception message and backtrace', :aggregrate_failures do
          web_request
          expect(response.code).to eql "500"
          json = JSON.parse(response.body)
          expect(json["summary"]).to eql "uninitialized constant Spree::Flowlink::Handler::UpblateOrderHandler"
          expect(json["backtrace"]).to be_present
        end

        context 'with an error_notifier' do
          before { Spree::Flowlink::WebhookController.error_notifier = error_notifier }
          after { Spree::Flowlink::WebhookController.error_notifier = nil }
          let(:error_notifier) { -> (_responder) {} }

          it 'calls the error_notifier' do
            expect(error_notifier).to receive(:call)
            web_request
          end
        end
      end
    end
  end
end
