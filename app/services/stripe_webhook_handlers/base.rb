module StripeWebhookHandlers
  class Base
    attr_accessor :event_data

    Result = Struct.new(:success?, :error_message, :data, keyword_init: true)

    def call(event_data)
      @event_data = event_data

      validate_event_data
      process_event
      Result.new(success?: true, data: event_data)
    rescue => e
      Rails.logger.error "#{self.class.name} error: #{e.message}"
      Result.new(success?: false, error_message: e.message)
    end

    private

    def process_event
      raise NotImplementedError, "Subclasses must implement process_event"
    end

    def validate_event_data
      raise ArgumentError, "Event data cannot be nil" if event_data.nil?
    end

    def user
      @user ||= User.find_by(stripe_customer_id: event_data["customer"])
    end
  end
end
