class User < ApplicationRecord
  include PasswordAuthentication

  password_authenticable

  has_many :subscriptions, dependent: :destroy
end
