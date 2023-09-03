require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup { ActionMailer::Base.deliveries.clear }

  test "should send verification code by email to new user" do
    post "/auth", params: { email: "test@example.com" }

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first

    assert_equal ["test@example.com"], email.to
    assert_equal "#{User.last.auth_code} is your verification code",
                 email.subject
    assert_redirected_to auth_verification_path
  end

  test "should send verification code by email to existing user" do
    @user = users(:one)
    post "/auth", params: { email: @user.email }

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first

    assert_equal ["bob@example.com"], email.to
    assert_equal "#{@user.auth_code} is your verification code", email.subject
    assert_redirected_to auth_verification_path
  end

  test "should create access_token for user when they enter a valid verification code" do
    @user = users(:one)
    post "/auth", params: { email: @user.email }
    post "/auth_verification",
         params: {
           email: @user.email,
           verification_code: @user.auth_code
         }

    cookie_jar =
      ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    access_token = cookie_jar.encrypted[:access_token]

    assert_equal access_token, @user.access_tokens.last.token
    assert_redirected_to root_path
  end

  test "should not create access_token for user when they enter an invalid verification code" do
    @user = users(:one)
    post "/auth", params: { email: @user.email }
    post "/auth_verification",
         params: {
           email: @user.email,
           verification_code: "invalid_verificaton_code"
         }

    cookie_jar =
      ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    access_token = cookie_jar.encrypted[:access_token]

    assert_not_equal access_token, @user.access_tokens.last.token
    assert_redirected_to auth_verification_path
  end

  test "should create an auth secret and verification code via API" do
    @user = users(:one)
    post "/auth.json", params: { email: @user.email }

    response_data = JSON.parse(response.body)
    verification_code = @user.auth_code

    assert_response :success
    assert_equal "verification-email-sent", response_data["msg"]

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first

    assert_equal ["bob@example.com"], email.to
    assert_equal "#{verification_code} is your verification code", email.subject
  end

  test "should create access_token for user when they enter a valid verification code via API" do
    @user = users(:one)
    post "/auth.json", params: { email: @user.email }

    response_data = JSON.parse(response.body)
    verification_code = @user.auth_code

    post "/auth_verification.json",
         params: {
           email: @user.email,
           verification_code: @user.auth_code
         },
         as: :json

    response_data = JSON.parse(response.body)

    assert_equal response_data["token"], @user.access_tokens.last.token
    assert_response :success
  end

  test "should not create access_token for user when they enter an invalid verification code via API" do
    @user = users(:one)
    post "/auth.json", params: { email: @user.email }, as: :json

    response_data = JSON.parse(response.body)
    salt = response_data["token"]

    post "/auth_verification.json",
         params: {
           email: @user.email,
           verification_code: "invalid_verificaton_code"
         },
         as: :json

    response_data = JSON.parse(response.body)

    assert_not_equal response_data["token"], @user.access_tokens.last.token
    assert_response :unauthorized
  end
end
