require "test_helper"

class MaintenancePlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user

    @asset_category = asset_categories(:one)
    @component = components(:one)
    @sub_component = sub_components(:one)
    @maintenance_plan = maintenance_plans(:one)
  end

  test "should get index" do
    get maintenance_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_maintenance_plan_url
    assert_response :success
  end

  test "should create maintenance_plan" do
    assert_difference("MaintenancePlan.count") do
      post maintenance_plans_url, params: {
        asset_category_id: @asset_category.id,
        maintenance_plan: {
          name: "New Plan",
          frequency: 500,
          unit: "Horas",
          details: "Check something",
          sub_component_id: @sub_component.id
        }
      }
    end

    assert_redirected_to maintenance_plans_url
  end

  test "should create maintenance_plan with new structure" do
    assert_difference(["MaintenancePlan.count", "SubComponent.count"], 1) do
      post maintenance_plans_url, params: {
        asset_category_id: @asset_category.id,
        component_id: @component.id,
        new_sub_component_name: "New SubComponent",
        maintenance_plan: {
          name: "Plan with New Sub",
          frequency: 100,
          unit: "Días",
          details: "Details"
        }
      }
    end

    assert_redirected_to maintenance_plans_url
  end
end
