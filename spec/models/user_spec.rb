require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe '#password' do
    let(:user) { User.new }

    it 'sets the password digest when a new password is assigned' do
      user.password = 'securepassword'
      expect(user.password_digest).to be_present
    end

    it 'returns a Password object when accessing the password' do
      user.password = 'securepassword'
      expect(user.password).to be_a(BCrypt::Password)
    end
  end

  describe '#authenticate' do
    let(:user) { User.create(email: 'test@gmail.com', password: 'securepassword') }

    it 'returns true for correct password' do
      expect(user.authenticate('securepassword')).to be true
    end

    it 'returns false for incorrect password' do
      expect(user.authenticate('wrongpassword')).to be false
    end
  end
end
