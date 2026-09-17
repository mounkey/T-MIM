require "test_helper"

class Superadmin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
  end

  test "should get index" do
    get superadmin_accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_account_url
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post superadmin_accounts_url, params: { account: {} }
    end

    assert_redirected_to superadmin_account_url(Account.last)
  end

  test "should show account" do
    get superadmin_account_url(@account)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    patch superadmin_account_url(@account), params: { account: {} }
    assert_redirected_to superadmin_account_url(@account)
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete superadmin_account_url(@account)
    end

    assert_redirected_to superadmin_accounts_url
  end
end
