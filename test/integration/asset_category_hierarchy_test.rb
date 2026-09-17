require "test_helper"

class AssetCategoryHierarchyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:two) # 'two' has role 1 (Admin) based on fixtures
    sign_in @admin
  end

  test "should create asset category with nested components and sub_components" do
    assert_difference -> { AssetCategory.count } => 1, -> { Component.count } => 1, -> { SubComponent.count } => 2 do
      post asset_categories_path, params: {
        asset_category: {
          name: "Test Hierarchy",
          description: "Testing nested forms",
          components_attributes: [
            {
              name: "Engine System",
              sub_components_attributes: [
                { name: "Oil Filter" },
                { name: "Spark Plugs" }
              ]
            }
          ]
        }
      }
    end

    category = AssetCategory.last
    assert_equal "Test Hierarchy", category.name
    assert_equal 1, category.components.count

    component = category.components.first
    assert_equal "Engine System", component.name
    assert_equal 2, component.sub_components.count
    assert_includes component.sub_components.pluck(:name), "Oil Filter"
  end

  test "should update hierarchy by adding components" do
    category = AssetCategory.create!(name: "Update Test")

    assert_difference -> { Component.count } => 1 do
      patch asset_category_path(category), params: {
        asset_category: {
          name: "Update Test",
          components_attributes: [
            { name: "Brakes" }
          ]
        }
      }
    end

    assert_equal "Brakes", category.components.first.name
  end

  test "should remove components via nested attributes" do
    category = AssetCategory.create!(name: "Delete Test")
    component = category.components.create!(name: "To Delete")

    assert_difference -> { Component.count } => -1 do
      patch asset_category_path(category), params: {
        asset_category: {
          name: "Delete Test",
          components_attributes: [
            { id: component.id, _destroy: "1" }
          ]
        }
      }
    end
  end
end
