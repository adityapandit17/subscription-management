class User < ApplicationRecord
  include PasswordAuthentication

  password_authenticable
end
