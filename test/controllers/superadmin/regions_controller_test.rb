require "test_helper"

class Superadmin::RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @region = regions(:one)
  end

  test "should get index" do
    get superadmin_regions_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_region_url
    assert_response :success
  end

  test "should create region" do
    assert_difference("Region.count") do
      post superadmin_regions_url, params: { region: {} }
    end

    assert_redirected_to superadmin_region_url(Region.last)
  end

  test "should show region" do
    get superadmin_region_url(@region)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_region_url(@region)
    assert_response :success
  end

  test "should update region" do
    patch superadmin_region_url(@region), params: { region: {} }
    assert_redirected_to superadmin_region_url(@region)
  end

  test "should destroy region" do
    assert_difference("Region.count", -1) do
      delete superadmin_region_url(@region)
    end

    assert_redirected_to superadmin_regions_url
  end
end
