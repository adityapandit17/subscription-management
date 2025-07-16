# frozen_string_literal: true

# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  before_action :require_login

  def index
    @subscriptions = Subscription.includes(:user)

    if params[:status].present? && Subscription.statuses.key?(params[:status])
      @subscriptions = @subscriptions.where(status: params[:status])
    end

    @subscriptions = @subscriptions.page(params[:page]).per(5)
    @current_filter = params[:status]
  end
end
