class User < ApplicationRecord
  include BCrypt

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :password, presence: true

  def password
    @password = Password.new(password_digest) if password_digest.present?
  end

  def password=(new_password)
    @password = Password.create(new_password) if new_password.present?
    self.password_digest = @password.to_s if @password
  end

  def authenticate(submitted_password)
    password == submitted_password
  end
end
