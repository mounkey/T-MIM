require "test_helper"

class Superadmin::CitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @city = cities(:one)
  end

  test "should get index" do
    get superadmin_cities_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_city_url
    assert_response :success
  end

  test "should create city" do
    assert_difference("City.count") do
      post superadmin_cities_url, params: { city: {} }
    end

    assert_redirected_to superadmin_city_url(City.last)
  end

  test "should show city" do
    get superadmin_city_url(@city)
    assert_response :success
  end

  test "should get edit" do
    get edit_superadmin_city_url(@city)
    assert_response :success
  end

  test "should update city" do
    patch superadmin_city_url(@city), params: { city: {} }
    assert_redirected_to superadmin_city_url(@city)
  end

  test "should destroy city" do
    assert_difference("City.count", -1) do
      delete superadmin_city_url(@city)
    end

    assert_redirected_to superadmin_cities_url
  end
end
