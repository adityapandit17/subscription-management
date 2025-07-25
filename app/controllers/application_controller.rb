class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include SessionsHelper

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    return if current_user

    flash[:alert] = "You must be logged in to access this section."
    redirect_to login_path
  end
end
