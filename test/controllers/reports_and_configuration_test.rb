require "test_helper"

class ReportsAndConfigurationTest < ActionDispatch::IntegrationTest
  setup do
    @account = Account.create!(name: "Taller Principal", subdomain: "tallerprincipal", rut: "76.444.333-2", email: "principal@tmim.cl")
    host! "tallerprincipal.example.com"
    ActsAsTenant.current_tenant = @account
    @user = User.create!(
      email: "admin_reportes@tmim.cl",
      name: "Admin Reportes",
      run: "18.111.222-3",
      password: "password123",
      account: @account
    )
    @category = AssetCategory.create!(name: "Automóviles", account: @account)
    @tag = Tag.create!(name: "Etiqueta General", color: "#336699", account: @account)
    @asset = Asset.create!(
      name: "Hyundai Tucson 2023",
      plate: "HYUN-99",
      make: "Hyundai",
      model: "Tucson",
      year: 2023,
      asset_category: @category,
      tag: @tag,
      account: @account,
      status: :operativa
    )
    @item = WarehouseItem.create!(
      name: "Líquido de Frenos DOT4",
      sku: "DOT4-01",
      category: "Frenos",
      unit: "Litro",
      stock_quantity: 15.0,
      minimum_stock: 3.0,
      cost_price: 4000.0,
      sale_price: 9000.0,
      account: @account
    )
  end

  test "Unauthenticated user is redirected to login for reports and config" do
    get reports_path
    assert_redirected_to new_user_session_path

    get inventory_report_path
    assert_redirected_to new_user_session_path

    get vehicle_latest_repair_report_path(@asset)
    assert_redirected_to new_user_session_path

    get warehouse_categories_path
    assert_redirected_to new_user_session_path

    get measurement_units_path
    assert_redirected_to new_user_session_path
  end

  test "Authenticated user can access Reports Hub and Inventory Report" do
    post user_session_path, params: { user: { email: @user.email, password: "password123" } }
    assert_response :redirect

    get reports_path
    assert_response :success

    get inventory_report_path
    assert_response :success
  end

  test "Authenticated user can access Vehicle Latest Repair and Full History Reports" do
    post user_session_path, params: { user: { email: @user.email, password: "password123" } }
    assert_response :redirect

    get vehicle_latest_repair_report_path(@asset)
    assert_response :success

    get vehicle_full_history_report_path(@asset)
    assert_response :success
  end

  test "Authenticated user can access and create Warehouse Categories and Measurement Units" do
    post user_session_path, params: { user: { email: @user.email, password: "password123" } }
    assert_response :redirect

    get warehouse_categories_path
    assert_response :success

    post warehouse_categories_path, params: {
      warehouse_category: { name: "Climatización y A/C", description: "Gas refrigerante y compresores" }
    }
    assert_redirected_to warehouse_categories_path
    assert WarehouseCategory.find_by(name: "Climatización y A/C", account: @account).present?

    get measurement_units_path
    assert_response :success

    post measurement_units_path, params: {
      measurement_unit: { name: "Botella (1L)", abbreviation: "bot", description: "Envase de 1 litro" }
    }
    assert_redirected_to measurement_units_path
    assert MeasurementUnit.find_by(name: "Botella (1L)", account: @account).present?
  end
end
