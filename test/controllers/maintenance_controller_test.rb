require "test_helper"

class MaintenanceControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get maintenance_url
    assert_response :success
  end
end
