require "test_helper"

class SmartLogbookTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @asset = assets(:one)
    @category = asset_categories(:one)

    # Ensure asset has the correct category and structure for testing
    @asset.update!(asset_category: @category)

    # Setup hierarchy
    @component = Component.create!(name: "Test Group", asset_category: @category)
    @sub_component = SubComponent.create!(name: "Test Part", component: @component)

    sign_in @user
  end

  test "should create logbook record with entries and checks" do
    meter = @asset.meters.create!(name: "KM", unit: "km", current_value: 1000)

    assert_difference -> { LogbookRecord.count } => 1,
                      -> { LogbookEntry.count } => 1,
                      -> { MaintenanceCheck.count } => 1 do
      post logbook_index_path, params: {
        asset_id: @asset.id,
        readings: {
          meter.id => 1100
        },
        checks: {
          @sub_component.id => { status: "issue", notes: "Ruido extraño" }
        },
        remarks: "Prueba de integración"
      }
    end

    record = LogbookRecord.last
    assert_equal @asset, record.asset
    assert_equal @user, record.user

    entry = record.logbook_entries.first
    assert_equal 1100, entry.current_value
    assert_equal 100, entry.quantity

    check = record.maintenance_checks.first
    assert_equal "issue", check.status
    assert_equal "Ruido extraño", check.notes
    assert_equal @sub_component, check.sub_component
  end
end
