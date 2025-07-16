FactoryBot.define do
  factory :subscription do
    association :user
    status { :paid } # Using the correct enum value
    stripe_subscription_id { "sub_#{SecureRandom.alphanumeric(14)}" }
    current_period_start { Time.current }
    current_period_end { 1.month.from_now }
  end
end
