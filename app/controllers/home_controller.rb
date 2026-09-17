class HomeController < ApplicationController
  def index
    # 1. KPIs
    @total_assets = Asset.count

    # We use the cached current_status in MaintenanceState.
    # Note: An asset might have multiple plans. If ANY plan is red, the asset is critical.
    # We need to get distinct assets for each status priority.

    # Get all states
    all_states = MaintenanceState.all

    # Group by asset and find worst status
    # 0: white, 1: yellow, 2: orange, 3: red
    asset_statuses = all_states.group_by(&:asset_id).transform_values do |states|
      # Safely map status string to integer, defaulting to 0 if nil
      # Then find max, defaulting to 0 if list is empty
      states.map { |s| MaintenanceState.current_statuses[s.current_status] || 0 }.max || 0
    end

    # Count stats
    @critical_count = asset_statuses.values.count { |v| v == 3 }
    @warning_count = asset_statuses.values.count { |v| v == 2 }
    # Operational includes White(0) and Yellow(1) (Yellow is just "performed recently", perfectly fine)
    # Also include assets with NO maintenance states (assumed new/ok)
    assets_with_state = asset_statuses.keys
    assets_without_state = Asset.where.not(id: assets_with_state).count

    @operational_count = asset_statuses.values.count { |v| v <= 1 } + assets_without_state

    @availability = @total_assets > 0 ? ((@operational_count.to_f / @total_assets) * 100).round : 0

    # 2. Top Priority List
    # We want assets with Red status first, then Orange.
    critical_asset_ids = asset_statuses.select { |k, v| v == 3 }.keys
    warning_asset_ids = asset_statuses.select { |k, v| v == 2 }.keys

    # Fetch objects
    @priority_assets = Asset.where(id: critical_asset_ids + warning_asset_ids)
                            .includes(:asset_category, :maintenance_states)
                            .limit(5)

    # Sort in Ruby to respect Red > Orange (DB fetch doesn't guarantee order of IDs list)
    @priority_assets = @priority_assets.sort_by do |asset|
      status_val = asset_statuses[asset.id] || 0
      -status_val # Descending order (3 down to 0)
    end

    # 3. Access Shortcuts
    @dashboard_categories = AssetCategory.where.not(icon: [nil, ""])
  end
end
