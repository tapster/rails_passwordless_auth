class AuthMailer < ApplicationMailer
  def auth_code(user, auth_code)
    @user = user
    @auth_code = auth_code

    mail(to: @user.email, subject: "#{@auth_code} is your verification code")
  end
end

