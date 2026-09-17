require "test_helper"

class ComponentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    component = Component.new(
      name: "Motor",
      asset_category: asset_categories(:one)
    )
    assert component.valid?
  end

  test "should require a name" do
    component = Component.new(
      name: nil,
      asset_category: asset_categories(:one)
    )
    assert_not component.valid?
    assert_includes component.errors[:name], "no puede estar en blanco"
  end

  test "should validate uniqueness of name scoped to asset category" do
    asset_category = asset_categories(:one)
    Component.create!(name: "Motor", asset_category: asset_category)

    duplicate_component = Component.new(name: "Motor", asset_category: asset_category)
    assert_not duplicate_component.valid?
    assert_includes duplicate_component.errors[:name], "ya está en uso"
  end

  test "should allow same name in different asset categories" do
    Component.create!(name: "Motor", asset_category: asset_categories(:one))

    other_component = Component.new(name: "Motor", asset_category: asset_categories(:two))
    assert other_component.valid?
  end

  test "should destroy associated sub_components when destroyed" do
    component = Component.create!(name: "Motor", asset_category: asset_categories(:one))
    component.sub_components.create!(name: "Bujía")

    assert_difference "SubComponent.count", -1 do
      component.destroy
    end
  end
end
