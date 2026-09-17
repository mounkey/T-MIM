require "test_helper"

class AssetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
    @asset = assets(:one)
  end

  test "should get index" do
    get assets_url
    assert_response :success
  end

  test "should get new" do
    get new_asset_url
    assert_response :success
  end

  test "should create asset" do
    assert_difference("Asset.count") do
      post assets_url, params: { asset: {
        name: "New Asset",
        status: "operativa",
        asset_category_id: @asset.asset_category_id,
        tag_id: @asset.tag_id
      } }
    end

    assert_redirected_to asset_url(Asset.last)
  end

  test "should show asset" do
    get asset_url(@asset)
    assert_response :success
  end

  test "should get edit" do
    get edit_asset_url(@asset)
    assert_response :success
  end

  test "should update asset" do
    patch asset_url(@asset), params: { asset: { name: "Updated Asset" } }
    assert_redirected_to asset_url(@asset)
    assert_equal "Updated Asset", @asset.reload.name
  end

  test "should destroy asset" do
    assert_difference("Asset.count", -1) do
      delete asset_url(@asset)
    end

    assert_redirected_to assets_url
  end
end
