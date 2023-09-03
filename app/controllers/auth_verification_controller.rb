class AuthVerificationController < ApplicationController
  def create
    user = User.find_by(email: session[:email])

    if user.present? && user.valid_auth_code?(params[:verification_code])
      access_token = user.access_tokens.create!
      cookies.permanent.encrypted[:access_token] = access_token.token

      session.delete(:email)

      redirect_to root_path, notice: "You are now signed in!"
    else
      redirect_to auth_verification_path, notice: "Please check your verification code and try again."
    end
  end

  def show
  end
end

