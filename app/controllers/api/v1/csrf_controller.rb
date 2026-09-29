class Api::V1::CsrfController < Api::BaseController
  # GET /api/v1/csrf — issues a fresh CSRF token (client retries once after a
  # stale-token rejection instead of failing the write).
  def show
    render json: { token: form_authenticity_token }
  end
end
