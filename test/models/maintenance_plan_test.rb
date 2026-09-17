require "test_helper"

class MaintenancePlanTest < ActiveSupport::TestCase
  setup do
    @category = AssetCategory.create!(name: "Test Cat", icon: "fa-truck")
    @component = @category.components.create!(name: "Engine")
    @sub_component = @component.sub_components.create!(name: "Filter")
  end

  test "should be valid with valid attributes" do
    plan = @sub_component.maintenance_plans.new(name: "Oil Change", frequency: 5000, unit: "KM")
    assert plan.valid?
  end

  test "should require name" do
    plan = @sub_component.maintenance_plans.new(frequency: 5000, unit: "KM")
    assert_not plan.valid?
    assert_includes plan.errors[:name], "no puede estar en blanco"
  end

  test "should require frequency" do
    plan = @sub_component.maintenance_plans.new(name: "Oil Change", unit: "KM")
    assert_not plan.valid?
    assert_includes plan.errors[:frequency], "no puede estar en blanco"
  end

  test "should require unit" do
    plan = @sub_component.maintenance_plans.new(name: "Oil Change", frequency: 5000)
    assert_not plan.valid?
    assert_includes plan.errors[:unit], "no puede estar en blanco"
  end
end
