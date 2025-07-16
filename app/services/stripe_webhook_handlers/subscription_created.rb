module StripeWebhookHandlers
  class SubscriptionCreated < Base
    private

    def process_event
      return unless user

      # Use find_or_create_by to handle potential duplicates
      subscription = user.subscriptions.find_or_create_by(
        stripe_subscription_id: event_data["id"]
      ) do |sub|
        sub.status = :unpaid
        sub.current_period_start = Time.at(event_data["current_period_start"])
        sub.current_period_end = Time.at(event_data["current_period_end"])
      end

      Rails.logger.info "Subscription created/found: #{subscription.id}"

      subscription
    end
  end
end
