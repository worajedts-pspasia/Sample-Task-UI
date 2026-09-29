class Api::BaseController < ApplicationController
  # Token-authenticated API clients (Authorization: Token <api_token>) have no
  # CSRF token; skip verification only for them. Session-cookie SPA requests
  # keep full CSRF protection.
  skip_before_action :verify_authenticity_token, if: -> { request.headers["Authorization"].present? }

  before_action :set_json_format, prepend: true
  before_action :require_api_user!

  private

  def set_json_format
    request.format = :json
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: "invalid_record", details: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: "param_missing", details: e.message }, status: :bad_request
  end

  private

  def task_scope
    current_user.tasks
  end
end
