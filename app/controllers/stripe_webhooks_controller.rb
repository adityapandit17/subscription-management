# frozen_string_literal: true

# app/controllers/stripe_webhooks_controller.rb
class StripeWebhooksController < ApplicationController
  include WebhookVerification

  protect_from_forgery with: :null_session

  def create
    case @event["type"]
    when "customer.subscription.created"
      StripeWebhookHandlers::SubscriptionCreated.new.call(event_payload)
    when "customer.subscription.deleted"
      StripeWebhookHandlers::SubscriptionDeleted.new.call(event_payload)
    when "invoice.payment_succeeded"
      StripeWebhookHandlers::InvoicePaymentSucceeded.new.call(event_payload)
    end

    head :ok
  end

  private

  def event_type
    @event_type ||= @event["type"]
  end

  def event_payload
    @event_payload ||= @event["data"]["object"]
  end
end
