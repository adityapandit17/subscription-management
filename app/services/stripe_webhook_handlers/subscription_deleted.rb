module StripeWebhookHandlers
  class SubscriptionDeleted < Base
    private

    def process_event
      return unless user

      subscription = user.subscriptions.find_by(
        stripe_subscription_id: event_data["id"]
      )
      return unless subscription

      subscription.update!(status: :canceled)
      Rails.logger.info "Subscription canceled: #{subscription.id}"

      subscription
    end
  end
end
