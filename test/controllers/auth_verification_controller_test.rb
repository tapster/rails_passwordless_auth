require "test_helper"

class AuthVerificationControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get auth_verification_url
    assert_response :success
  end

  test "should get show" do
    get auth_verification_url
    assert_response :success
  end
end
