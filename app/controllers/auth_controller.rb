class AuthController < ApplicationController
  def show
  end

  def create
    email = params[:email].downcase.strip
    user = User.find_or_create_by(email: email)

    AuthMailer.auth_code(user, user.auth_code).deliver_now

    session[:email] = email

    redirect_to auth_verification_path
  end

  def destroy
    cookies.delete :access_token

    redirect_to root_path, notice: "You're now signed out"
  end
end

