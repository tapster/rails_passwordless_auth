class User < ApplicationRecord
  before_create :generate_otp_secret
  has_many :access_tokens, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def auth_code
    totp.now
  end

  def valid_auth_code?(code)
    totp.verify(code, drift_behind: 300).present?
  end

  private

  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random(16)
  end

  def totp
    ROTP::TOTP.new(otp_secret, issuer: "Your App Name")
  end
end

