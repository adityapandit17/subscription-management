# frozen_string_literal: true

# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :require_login

  def index
    @subscriptions = Subscription.includes(:user).page(params[:page]).per(5)
  end
end
