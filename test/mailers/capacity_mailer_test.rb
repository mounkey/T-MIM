require "test_helper"

class CapacityMailerTest < ActionMailer::TestCase
  test "capacity_warning_email" do
    mail = CapacityMailer.capacity_warning_email
    assert_equal "Capacity warning email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
