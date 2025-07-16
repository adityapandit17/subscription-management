# frozen_string_literal: true

# app/controllers/concerns/webhook_verification.rb
module WebhookVerification
  extend ActiveSupport::Concern

  included do
    before_action :verify_webhook_signature
  end

  private

  def verify_webhook_signature
    @event = Stripe::Webhook.construct_event(
      request.body.read,
      request.headers["HTTP_STRIPE_SIGNATURE"],
      webhook_secret
    )
  rescue JSON::ParserError => e
    render json: { error: "Invalid payload" }, status: :bad_request
  rescue Stripe::SignatureVerificationError => e
    render json: { error: "Invalid signature" }, status: :bad_request
  end

  def webhook_secret
    Rails.application.credentials.dig(Rails.env.to_sym, :stripe, :stripe_webhook_secret)
  end
end
