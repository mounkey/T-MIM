require "test_helper"

class SubComponentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    component = components(:one)
    sub_component = SubComponent.new(
      name: "Aceite",
      component: component
    )
    assert sub_component.valid?
  end

  test "should require a name" do
    component = components(:one)
    sub_component = SubComponent.new(
      name: nil,
      component: component
    )
    assert_not sub_component.valid?
    assert_includes sub_component.errors[:name], "no puede estar en blanco"
  end

  test "should validate uniqueness of name scoped to component" do
    component = components(:one)
    SubComponent.create!(name: "Aceite", component: component)

    duplicate = SubComponent.new(name: "Aceite", component: component)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "ya está en uso"
  end

  test "should allow same name in different components" do
    SubComponent.create!(name: "Aceite", component: components(:one))

    other = SubComponent.new(name: "Aceite", component: components(:two))
    assert other.valid?
  end
end
