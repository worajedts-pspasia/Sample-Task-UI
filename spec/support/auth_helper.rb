module AuthHelper
  def api_sign_in
    @user = User.create!(email: "spec@things.local", password: "specpass", password_confirmation: "specpass")
    @headers = { "Authorization" => "Token #{@user.api_token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
