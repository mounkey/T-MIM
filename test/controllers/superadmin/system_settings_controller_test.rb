require "test_helper"

class Superadmin::SystemSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system_setting = system_settings(:one)
  end

  test "should get index" do
    get superadmin_system_settings_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_system_setting_url
    assert_response :success
  end

  test "should create system_setting" do
    assert_difference("SystemSetting.count") do
      post superadmin_system_settings_url, params: { system_setting: {} }
    end

    assert_redirected_to superadmin_system_setting_url(SystemSetting.last)
  end

  test "should show system_setting" do
    get superadmin_system_setting_url(@system_setting)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_system_setting_url(@system_setting)
    assert_response :success
  end

  test "should update system_setting" do
    patch superadmin_system_setting_url(@system_setting), params: { system_setting: {} }
    assert_redirected_to superadmin_system_setting_url(@system_setting)
  end

  test "should destroy system_setting" do
    assert_difference("SystemSetting.count", -1) do
      delete superadmin_system_setting_url(@system_setting)
    end

    assert_redirected_to superadmin_system_settings_url
  end
end
