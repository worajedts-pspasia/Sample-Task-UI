class Api::V1::ProfileController < Api::BaseController
  # PATCH /api/v1/profile — update the signed-in user (locale).
  def update
    current_user.update!(params.require(:user).permit(:locale))
    render json: { email: current_user.email, locale: current_user.locale }
  end
end
