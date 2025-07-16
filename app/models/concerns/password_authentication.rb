# frozen_string_literal: true

module PasswordAuthentication
  extend ActiveSupport::Concern

  included do
    include BCrypt
    validates :email, presence: true, uniqueness: true
    validates :password, length: { minimum: 6 }, allow_nil: true
    validates :password, presence: true
  end

  def password
    @password = BCrypt::Password.new(password_digest) if password_digest.present?
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password) if new_password.present?
    self.password_digest = @password.to_s if @password
  end

  def authenticate(submitted_password)
    password == submitted_password
  end

  class_methods do
    def password_authenticable
      include PasswordAuthentication
    end
  end
end
