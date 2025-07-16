module StripeWebhookHandlers
  class InvoicePaymentSucceeded < Base
    private

    def process_event
      return unless user

      subscription = user.subscriptions.find_by(
        stripe_subscription_id: event_data["subscription"]
      )
      return unless subscription

      subscription.update!(status: :paid)
      Rails.logger.info "Subscription payment succeeded: #{subscription.id}"

      subscription
    end
  end
end
