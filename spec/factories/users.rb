# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
  end
end
