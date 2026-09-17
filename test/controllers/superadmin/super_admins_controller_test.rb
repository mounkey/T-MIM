require "test_helper"

class Superadmin::SuperAdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @super_admin = super_admins(:one)
  end

  test "should get index" do
    get superadmin_super_admins_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_super_admin_url
    assert_response :success
  end

  test "should create super_admin" do
    assert_difference("SuperAdmin.count") do
      post superadmin_super_admins_url, params: { super_admin: {} }
    end

    assert_redirected_to superadmin_super_admin_url(SuperAdmin.last)
  end

  test "should show super_admin" do
    get superadmin_super_admin_url(@super_admin)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_super_admin_url(@super_admin)
    assert_response :success
  end

  test "should update super_admin" do
    patch superadmin_super_admin_url(@super_admin), params: { super_admin: {} }
    assert_redirected_to superadmin_super_admin_url(@super_admin)
  end

  test "should destroy super_admin" do
    assert_difference("SuperAdmin.count", -1) do
      delete superadmin_super_admin_url(@super_admin)
    end

    assert_redirected_to superadmin_super_admins_url
  end
end
