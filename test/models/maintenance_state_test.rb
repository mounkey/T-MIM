require "test_helper"

class MaintenanceStateTest < ActiveSupport::TestCase
  setup do
    @category = AssetCategory.create!(name: "Test Cat", icon: "fa-truck")
    @component = @category.components.create!(name: "Engine")
    @sub_component = @component.sub_components.create!(name: "Filter")
    @plan = @sub_component.maintenance_plans.create!(name: "Oil Change", frequency: 5000, unit: "KM")

    @tag = Tag.create!(name: "Test Tag", color: "#000")
    @asset = Asset.create!(name: "Test Asset", status: :operativa, asset_category: @category, tag: @tag)
  end

  test "should be valid with valid attributes" do
    state = MaintenanceState.new(asset: @asset, maintenance_plan: @plan, last_performed_value: 100)
    assert state.valid?
  end

  test "should belong to asset" do
    state = MaintenanceState.new(maintenance_plan: @plan)
    assert_not state.valid?
    assert_includes state.errors[:asset], "debe existir"
  end

  test "should belong to plan" do
    state = MaintenanceState.new(asset: @asset)
    assert_not state.valid?
    assert_includes state.errors[:maintenance_plan], "debe existir"
  end
end
