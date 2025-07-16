# frozen_string_literal: true

module StripeWebhookHelper
  def generate_stripe_signature(payload, secret)
    timestamp = Time.now
    timestamp_i = timestamp.to_i
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload, secret)
    "t=#{timestamp_i},v1=#{signature}"
  end
end
