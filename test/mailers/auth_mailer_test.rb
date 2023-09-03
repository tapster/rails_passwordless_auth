require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "send invitation" do
    email = AuthMailer.auth_code(users(:one), "abc123")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["from@example.com"], email.from
    assert_equal ["bob@example.com"], email.to
    assert_equal "abc123 is your verification code", email.subject
    assert_match "Enter this code in the next 5 minutes to sign in: abc123",
                 email.body.to_s
  end
end
