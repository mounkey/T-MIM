require "test_helper"

class TmimUnitTest < ActiveSupport::TestCase
  setup do
    @account = Account.create!(name: "Taller Test", subdomain: "tallertest", rut: "76.123.456-7", email: "taller@tmim.cl")
    ActsAsTenant.current_tenant = @account
    @user = User.create!(
      email: "mecanico_test@tmim.cl",
      name: "Juan Mecanico",
      run: "15.999.888-K",
      password: "password123",
      account: @account
    )
    @category = AssetCategory.create!(name: "Camionetas 4x4", account: @account)
    @tag = Tag.create!(name: "Flota Minera", color: "#FF5733", account: @account)
    @asset = Asset.create!(
      name: "Toyota Hilux 2024",
      plate: "ABCD-12",
      make: "Toyota",
      model: "Hilux",
      year: 2024,
      asset_category: @category,
      tag: @tag,
      account: @account,
      status: :operativa
    )
  end

  test "WarehouseItem stock availability and calculations" do
    item = WarehouseItem.create!(
      name: "Aceite 5W30",
      sku: "OIL-5W30",
      category: "Lubricantes",
      unit: "Litro",
      stock_quantity: 20.0,
      reserved_quantity: 5.0,
      minimum_stock: 4.0,
      cost_price: 6000.0,
      sale_price: 12000.0,
      account: @account
    )

    assert_equal 15.0, item.available_stock
    assert_not item.low_stock?
    assert_not item.out_of_stock?
    assert_equal "bg-success", item.stock_status_badge[:class]

    # Simular stock bajo
    item.update!(stock_quantity: 3.0)
    assert item.low_stock?
    assert_equal "bg-warning text-dark", item.stock_status_badge[:class]

    # Simular agotado
    item.update!(stock_quantity: 0.0)
    assert item.out_of_stock?
    assert_equal "bg-danger", item.stock_status_badge[:class]
  end

  test "StockMovement updates WarehouseItem stock quantity automatically" do
    item = WarehouseItem.create!(
      name: "Filtro de Aceite",
      stock_quantity: 10.0,
      minimum_stock: 2.0,
      account: @account
    )

    # Ingreso de stock
    item.stock_movements.create!(
      user: @user,
      movement_type: :entry,
      quantity: 5.0,
      account: @account
    )
    assert_equal 15.0, item.reload.stock_quantity

    # Salida por consumo
    item.stock_movements.create!(
      user: @user,
      movement_type: :exit,
      quantity: 3.0,
      asset: @asset,
      account: @account
    )
    assert_equal 12.0, item.reload.stock_quantity
  end

  test "PaymentOrder financial status and balance calculations" do
    order = PaymentOrder.create!(
      asset: @asset,
      labor_amount: 50000.0,
      parts_amount: 30000.0,
      discount_amount: 10000.0,
      mechanical_status: :in_progress,
      account: @account
    )

    # Total = 50.000 + 30.000 - 10.000 = 70.000
    assert_equal 70000.0, order.total_amount
    assert_equal :unpaid, order.financial_status
    assert_equal 70000.0, order.balance_due

    # Abono parcial de 40.000
    order.payments.create!(
      user: @user,
      amount: 40000.0,
      payment_channel: :cash,
      recorded_at: Time.current,
      account: @account
    )

    assert_equal 40000.0, order.total_paid
    assert_equal 30000.0, order.balance_due
    assert_equal :partial, order.financial_status

    # Pago final del saldo de 30.000
    order.payments.create!(
      user: @user,
      amount: 30000.0,
      payment_channel: :pos_local,
      recorded_at: Time.current,
      account: @account
    )

    assert_equal 70000.0, order.total_paid
    assert_equal 0.0, order.balance_due
    assert_equal :paid, order.financial_status
  end

  test "Asset helper methods for reports" do
    order = PaymentOrder.create!(
      asset: @asset,
      labor_amount: 80000.0,
      parts_amount: 20000.0,
      account: @account
    )

    logbook = LogbookRecord.create!(
      asset: @asset,
      user: @user,
      recorded_at: Time.current,
      notes: "Mantención 10.000 km",
      account: @account
    )

    item = WarehouseItem.create!(
      name: "Pastillas de Freno",
      stock_quantity: 10.0,
      account: @account
    )

    item.stock_movements.create!(
      user: @user,
      movement_type: :exit,
      quantity: 2.0,
      asset: @asset,
      logbook_record: logbook,
      account: @account
    )

    assert_equal order, @asset.latest_payment_order
    assert_equal logbook, @asset.latest_logbook_record
    assert_equal 100000.0, @asset.total_spent_on_repairs
    assert_equal 2.0, @asset.total_parts_used_count
  end

  test "WarehouseCategory and MeasurementUnit seeding and isolation" do
    WarehouseCategory.seed_defaults_for_account!(@account)
    MeasurementUnit.seed_defaults_for_account!(@account)

    assert WarehouseCategory.where(account: @account).count >= 8
    assert MeasurementUnit.where(account: @account).count >= 9

    assert WarehouseCategory.find_by(name: "Lubricantes", account: @account).present?
    assert MeasurementUnit.find_by(name: "Litro", account: @account).present?
  end
end
