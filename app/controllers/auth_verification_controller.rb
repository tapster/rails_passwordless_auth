class AuthVerificationController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def create
    user = User.find_by(email: session[:email])

    if user.present? && user.valid_auth_code?(params[:verification_code])
      access_token = user.access_tokens.create!
      cookies.permanent.encrypted[:access_token] = access_token.token

      session.delete(:email)

      respond_to do |format|
        format.html { redirect_to root_path, notice: "You are now signed in" }
        format.json { render json: { token: access_token.token } }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to auth_verification_path,
                      notice:
                        "Please check your verification code and try again."
        end
        format.json do
          render json: {
                   msg: "invalid-verification-code."
                 },
                 status: :unauthorized
        end
      end
    end
  end

  def show
  end
end
