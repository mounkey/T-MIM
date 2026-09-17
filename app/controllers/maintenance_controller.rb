class MaintenanceController < ApplicationController
  before_action :authenticate_user!

  def index
    # Fetch all assets with eager loading
    assets = Asset.includes(:tag, :meters, :logbook_records, :maintenance_states, asset_category: { components: { sub_components: :maintenance_plans } })
                  .order('asset_categories.name', :name)
                  .references(:asset_categories)

    # Initialize hierarchy structure
    # { category_name => { asset => { component_name => [ { plan, status } ] } } }
    @hierarchy = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Hash.new { |h3, k3| h3[k3] = [] } } }

    # Counter for category-level alerts
    @category_alerts = Hash.new { |h, k| h[k] = { red: 0, orange: 0, yellow: 0 } }
    @asset_alerts = Hash.new { |h, k| h[k] = { red: 0, orange: 0, yellow: 0 } }

    assets.each do |asset|
      category_name = asset.asset_category.name
      components = asset.asset_category.components

      components.each do |component|
        sub_components = component.sub_components

        sub_components.each do |sub_component|
          plans = sub_component.maintenance_plans

          plans.each do |plan|
            # Optimization: Read from Cached State instead of calculating on the fly
            # We assume daily job or logbook entry updated the cache.
            # If state doesn't exist, we default to calculation (lazy init)

            # Find in memory association (eager loaded)
            state = asset.maintenance_states.find { |s| s.maintenance_plan_id == plan.id }

            status_symbol = :white # Default
            percentage = 0.0

            if state && state.current_status.present?
              status_symbol = state.current_status.to_sym
              percentage = state.percentage_used || 0.0

              # Reconstruct details hash for view compatibility (simplified)
              # Ideally view should use 'state' object, but we are keeping structure for now
              status = {
                status: status_symbol,
                percentage: percentage,
                target: state.next_due_at ? "Vence: #{state.next_due_at.strftime("%d/%m/%Y")}" : "Calculando...", # Simple fallback
                color_class: case status_symbol
                             when :red then 'bg-danger'
                             when :orange then 'bg-orange'
                             when :yellow then 'bg-warning'
                             else 'bg-success'
                             end
              }
            else
              # Fallback for un-initialized states
              service = MaintenanceStatusService.new(asset, plan)
              status = service.calculate # This is heavy but only happens once
            end

            # Apply Filtering
            next if params[:filter] == 'critical' && ![:red, :orange].include?(status[:status])
            next if params[:filter] == 'pending' && ![:red, :orange, :yellow].include?(status[:status])

            # Build Task Object
            task = {
              id: "#{asset.id}-#{plan.id}",
              plan: plan,
              status_details: status
            }

            # Add to Hierarchy
            @hierarchy[category_name][asset][component.name] << task

            # Update Alert Counters
            if status[:status] != :white
              @category_alerts[category_name][status[:status]] += 1
              @asset_alerts[asset.id][status[:status]] += 1
            end
          end
        end
      end
    end

    # Remove empty entries if filtering hid everything
    @hierarchy.delete_if { |_, assets_map| assets_map.empty? }
    @hierarchy.each do |_, assets_map|
      assets_map.delete_if { |_, components_map| components_map.values.flatten.empty? }
    end
  end
end
