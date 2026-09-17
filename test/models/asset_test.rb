require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @category = AssetCategory.create!(name: "Maquinaria Pesada")
    @tag = Tag.create!(name: "Crítica")
  end

  test "should be valid with valid attributes" do
    asset = Asset.new(
      name: "Excavadora",
      status: :operativa,
      asset_category: @category,
      tag: @tag
    )
    assert asset.valid?
  end

  test "should require a name" do
    asset = Asset.new(name: nil)
    assert_not asset.valid?
    # I18n is set to ES, so we check for Spanish message
    assert_includes asset.errors[:name], "no puede estar en blanco"
  end

  test "should default status to operativa" do
    asset = Asset.new
    assert_equal "operativa", asset.status
  end
end
