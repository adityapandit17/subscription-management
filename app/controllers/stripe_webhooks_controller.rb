# frozen_string_literal: true

# app/controllers/stripe_webhooks_controller.rb
class StripeWebhooksController < ApplicationController
  include WebhookVerification

  protect_from_forgery with: :null_session

  def create
    case @event["type"]
    when "customer.subscription.created"
      handle_subscription_created(event_payload)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event_payload)
    when "invoice.payment_succeeded"
      handle_subscription_payment_succeeded(event_payload)
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

  def handle_subscription_created(subscription_data)
    user = User.find_by(stripe_customer_id: subscription_data["customer"])
    return unless user

    subscription = user.subscriptions.create(
      status: :unpaid,
      stripe_subscription_id: subscription_data["id"],
      current_period_start: Time.at(subscription_data["current_period_start"]),
      current_period_end: Time.at(subscription_data["current_period_end"])
    )
  end

  def handle_subscription_deleted(subscription_data)
    user = User.find_by(stripe_customer_id: subscription_data["customer"])
    return unless user

    subscription = user.subscriptions.find_by(stripe_subscription_id: subscription_data["id"])
    return unless subscription

    subscription.update(status: :canceled)
  end

  def handle_subscription_payment_succeeded(invoice_data)
    user = User.find_by(stripe_customer_id: invoice_data["customer"])
    return unless user

    subscription = user.subscriptions.find_by(stripe_subscription_id: invoice_data["subscription"])
    return unless subscription

    subscription.update(status: :paid)
  end
end
