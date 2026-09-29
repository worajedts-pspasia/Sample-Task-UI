class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :destroy

  before_validation :ensure_api_token, on: :create
  before_validation { self.locale ||= "en" }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :locale, inclusion: { in: %w[en th ja] }

  def ensure_api_token
    self.api_token ||= SecureRandom.hex(20)
  end
end
