module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    helper_method :current_user, :user_signed_in?
  end

  private

  def current_user
    @current_user ||= begin
      if session[:user_id]
        User.find_by(id: session[:user_id])
      elsif request.headers["Authorization"].present?
        token = request.headers["Authorization"].remove(/\AToken\s+/i)
        User.find_by(api_token: token)
      end
    end
  end

  def user_signed_in? = current_user.present?

  def authenticate_user!
    return if user_signed_in?
    respond_to do |format|
      format.html { redirect_to login_path, alert: I18n.t("sessions.please_sign_in") }
      format.json { render json: { error: "unauthorized" }, status: :unauthorized }
    end
  end

  def require_api_user!
    head :unauthorized unless current_user
  end
end
