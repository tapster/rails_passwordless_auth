class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def show
  end

  def create
    email = params[:email].downcase.strip
    user = User.find_or_create_by(email: email)

    AuthMailer.auth_code(user, user.auth_code).deliver_now

    session[:email] = email

    respond_to do |format|
      format.html { redirect_to auth_verification_path }
      format.json { render json: { msg: "verification-email-sent" } }
    end
  end

  def destroy
    cookies.delete :access_token

    respond_to do |format|
      format.html { redirect_to root_path, notice: "You're now signed out" }
      format.json { render json: { msg: "signed-out" } }
    end
  end
end
