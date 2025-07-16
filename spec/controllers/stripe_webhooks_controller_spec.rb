# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeWebhooksController, type: :controller do
  include StripeWebhookHelper

  let(:webhook_secret) { 'whsec_test_secret' }
  let(:stripe_signature) { nil }
  let(:user) { FactoryBot.create(:user) }

  before do
    allow(Rails.application.credentials).to receive(:dig)
      .with(Rails.env.to_sym, :stripe, :stripe_webhook_secret)
      .and_return(webhook_secret)

    # Mock the request headers for HTTP_STRIPE_SIGNATURE
    request.headers['HTTP_STRIPE_SIGNATURE'] = stripe_signature if stripe_signature
  end

  describe 'POST #create' do
    context 'with invalid signature' do
      let(:payload) { { type: 'customer.subscription.created' }.to_json }
      let(:stripe_signature) { 'invalid_signature' }

      it 'returns a bad request status' do
        post :create, body: payload
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid signature')
      end
    end

    context 'with valid signature' do
      let(:payload) { JSON.dump(event_data) }
      let(:stripe_signature) do
        generate_stripe_signature(payload, webhook_secret)
      end

      context 'for customer.subscription.created event' do
        let(:subscription_id) { "sub_#{SecureRandom.alphanumeric(14)}" }
        let(:event_data) do
          {
            type: 'customer.subscription.created',
            data: {
              object: {
                id: subscription_id,
                customer: user.stripe_customer_id,
                status: 'active',
                current_period_start: Time.current.to_i,
                current_period_end: 1.month.from_now.to_i
              }
            }
          }
        end

        it 'creates a new subscription with unpaid status' do
          expect do
            post :create, body: payload
          end.to change(Subscription, :count).by(1)

          expect(response).to have_http_status(:ok)

          subscription = user.subscriptions.last
          expect(subscription.stripe_subscription_id).to eq(subscription_id)
          expect(subscription.status).to eq('unpaid')
        end
      end

      context 'for customer.subscription.deleted event' do
        let!(:subscription) { FactoryBot.create(:subscription, user: user) }
        let(:event_data) do
          {
            type: 'customer.subscription.deleted',
            data: {
              object: {
                id: subscription.stripe_subscription_id,
                customer: user.stripe_customer_id
              }
            }
          }
        end

        it 'marks the subscription as canceled' do
          post :create, body: payload
          expect(response).to have_http_status(:ok)

          subscription.reload
          expect(subscription.status).to eq('canceled')
        end
      end

      context 'for invoice.payment_succeeded event' do
        let!(:subscription) { FactoryBot.create(:subscription, user: user) }
        let(:event_data) do
          {
            type: 'invoice.payment_succeeded',
            data: {
              object: {
                subscription: subscription.stripe_subscription_id,
                customer: user.stripe_customer_id
              }
            }
          }
        end

        it 'marks the subscription as paid' do
          post :create, body: payload
          expect(response).to have_http_status(:ok)

          subscription.reload
          expect(subscription.status).to eq('paid')
        end
      end

      context 'for unsupported event type' do
        let(:event_data) do
          {
            type: 'unsupported.event',
            data: { object: {} }
          }
        end

        it 'returns ok but does not process the event' do
          expect do
            post :create, body: payload
          end.not_to change(Subscription, :count)

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
