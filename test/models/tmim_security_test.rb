require "test_helper"

class TmimSecurityTest < ActiveSupport::TestCase
  setup do
    @account_a = Account.create!(name: "Taller A - Santiago", subdomain: "tallera", rut: "76.111.111-1", email: "tallerA@tmim.cl")
    @account_b = Account.create!(name: "Taller B - Antofagasta", subdomain: "tallerb", rut: "76.222.222-2", email: "tallerB@tmim.cl")

    ActsAsTenant.current_tenant = @account_a
    @category_a = AssetCategory.create!(name: "Autos Taller A", account: @account_a)
    @tag_a = Tag.create!(name: "Tag A", account: @account_a)
    @item_a = WarehouseItem.create!(name: "Filtro Taller A", sku: "FLT-A", stock_quantity: 10, account: @account_a)
    @asset_a = Asset.create!(name: "Auto Taller A", plate: "AAAA-11", asset_category: @category_a, tag: @tag_a, account: @account_a)

    ActsAsTenant.current_tenant = @account_b
    @category_b = AssetCategory.create!(name: "Autos Taller B", account: @account_b)
    @tag_b = Tag.create!(name: "Tag B", account: @account_b)
    @item_b = WarehouseItem.create!(name: "Filtro Taller B", sku: "FLT-B", stock_quantity: 50, account: @account_b)
    @asset_b = Asset.create!(name: "Camioneta Taller B", plate: "BBBB-22", asset_category: @category_b, tag: @tag_b, account: @account_b)
  end

  test "Multi-tenant strict isolation for Assets" do
    ActsAsTenant.current_tenant = @account_a
    visible_assets = Asset.all
    assert_includes visible_assets, @asset_a
    assert_not_includes visible_assets, @asset_b

    ActsAsTenant.current_tenant = @account_b
    visible_assets = Asset.all
    assert_includes visible_assets, @asset_b
    assert_not_includes visible_assets, @asset_a
  end

  test "Multi-tenant strict isolation for Warehouse Items and Stock" do
    ActsAsTenant.current_tenant = @account_a
    visible_items = WarehouseItem.all
    assert_includes visible_items, @item_a
    assert_not_includes visible_items, @item_b

    ActsAsTenant.current_tenant = @account_b
    visible_items = WarehouseItem.all
    assert_includes visible_items, @item_b
    assert_not_includes visible_items, @item_a
  end

  test "WarehouseCategory and MeasurementUnit multi-tenant isolation" do
    ActsAsTenant.current_tenant = @account_a
    cat_a = WarehouseCategory.create!(name: "Filtros Especiales A", account: @account_a)
    unit_a = MeasurementUnit.create!(name: "Pack Especial A", abbreviation: "pkA", account: @account_a)

    ActsAsTenant.current_tenant = @account_b
    cat_b = WarehouseCategory.create!(name: "Filtros Especiales B", account: @account_b)

    assert_not_includes WarehouseCategory.all, cat_a
    assert_includes WarehouseCategory.all, cat_b
    assert_not_includes MeasurementUnit.all, unit_a
  end
end
