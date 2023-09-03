class ApplicationController < ActionController::Base
  helper_method :logged_in?, :current_user

  def current_user
    @current_user ||= lookup_user_by_cookie
  end

  def logged_in?
    !!current_user
  end

  private

  def lookup_user_by_cookie
    if cookies.permanent.encrypted[:access_token]
      User.joins(:access_tokens).find_by(
        access_tokens: {
          token: cookies.permanent.encrypted[:access_token]
        }
      )
    end
  end
end

