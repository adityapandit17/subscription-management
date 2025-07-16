# Create users
10.times do |i|
  User.find_or_create_by(email: "user#{i}@example.com") do |user|
    user.password = "password#{i}"
    user.stripe_customer_id = "cus_#{SecureRandom.alphanumeric(14)}"
  end
end

puts "Created #{User.count} users"

# Clear existing subscriptions
Subscription.destroy_all

# Create subscriptions with different statuses
users = User.all
statuses = Subscription.statuses.keys

users.each do |user|
  # Create 1-3 subscriptions for each user with different statuses
  rand(1..3).times do
    status = statuses.sample

    subscription = user.subscriptions.create!(
      status: status,
      stripe_subscription_id: "sub_#{SecureRandom.alphanumeric(14)}",
      current_period_start: Time.current - rand(1..30).days,
      current_period_end: status == 'canceled' ? Time.current - rand(1..10).days : Time.current + rand(1..30).days
    )

    puts "Created #{status} subscription for #{user.email}"
  end
end

puts "Created #{Subscription.count} subscriptions"
