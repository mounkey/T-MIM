class LogbookController < ApplicationController
  before_action :authenticate_user!

  def index
    # Tab 1: Timeline
    @logbook_records = LogbookRecord.includes(:user, :asset, :logbook_entries, :maintenance_checks).order(recorded_at: :desc).page(params[:page])

    # Tab 2: Audit Hierarchy (Categories -> Assets -> Plans -> History)
    # We fetch categories that have assets to build the structure.
    @audit_hierarchy = AssetCategory.includes(assets: [:maintenance_states, asset_category: :maintenance_plans])
                                    .where(id: Asset.select(:asset_category_id).distinct)

    # Optimization: Pre-fetch maintenance checks for all assets in the hierarchy
    # We use a separate query to avoid complex joins and duplicate data transfer
    asset_ids = Asset.where(asset_category_id: @audit_hierarchy.pluck(:id)).pluck(:id)

    all_checks = MaintenanceCheck.joins(:logbook_record)
                                 .where(logbook_records: { asset_id: asset_ids })
                                 .includes(logbook_record: [:user, logbook_entries: :meter])
                                 .order("logbook_records.recorded_at DESC")

    # Group by [asset_id, sub_component_id] for O(1) access in the view
    @checks_cache = all_checks.group_by { |c| [c.logbook_record.asset_id, c.sub_component_id] }
  end

  def show
    @logbook_record = LogbookRecord.includes(:asset, :user, logbook_entries: :meter, maintenance_checks: [:component, :sub_component]).find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "logbook/show_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "tarea_#{@logbook_record.id}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def new
    if params[:asset_id].present?
      @asset = Asset.find(params[:asset_id])
      @meters = @asset.meters
      @structure = @asset.maintenance_structure
    end

    # Pre-load assets for the select dropdown
    @assets_for_select = Asset.all.map { |a| ["#{a.name} - #{a.plate.presence || 'S/P'}", a.id] }
  end

  def create
    @asset = Asset.find(params[:asset_id])
    readings = params[:readings] || {}
    checks = params[:checks] || {}

    ActiveRecord::Base.transaction do
      # Create the Header (Logbook Record)
      record = LogbookRecord.create!(
        asset: @asset,
        user: current_user,
        recorded_at: Time.current
      )

      # Process Meter Readings
      readings.each do |meter_id, new_value|
        next if new_value.blank?

        meter = @asset.meters.find(meter_id)

        LogbookEntry.create!(
          logbook_record: record,
          meter: meter,
          user: current_user,
          current_value: new_value,
          remarks: params[:remarks] # Remarks are now effectively per-visit but stored on entry for legacy reasons? Or we should move remarks to Record.
          # For now, replicate remarks on all entries or just the first one?
          # Let's keep it simple: LogbookEntry has remarks. LogbookRecord doesn't yet.
        )
      end

      # Process Maintenance Checks
      checks.each do |sub_component_id, check_data|
        # check_data is expected to be { status: 'ok', notes: '...' }
        # or if it's just a status string if we simplify the form.
        # Let's assume params[:checks][sub_component_id][:status]

        status = check_data[:status]
        next if status.blank? # Only save checked items? Or should we save explicit 'ok'?

        sub_component = SubComponent.find(sub_component_id)

        MaintenanceCheck.create!(
          logbook_record: record,
          component: sub_component.component,
          sub_component: sub_component,
          status: status,
          notes: check_data[:notes]
        )

        # Logic Fix: Auto-reset Maintenance Plans if status is 'fixed' (reparado)
        if status == 'fixed'
          # Find all plans associated with this sub_component
          # (and optionally the asset category, but usually plan belongs to sub_component)
          plans = MaintenancePlan.where(sub_component: sub_component)

          plans.each do |plan|
            # Find or initialize state for this asset/plan
            state = MaintenanceState.find_or_initialize_by(asset: @asset, maintenance_plan: plan)

            # Update with current time
            state.last_performed_at = Time.current

            # Update with current meter value if applicable
            # The plan defines a unit (e.g., 'Horas'). We need the current value of that meter.
            meter = @asset.meters.find_by(unit: plan.unit)
            if meter
              state.last_performed_value = meter.current_value
            else
              # If time-based or no meter found, value might be irrelevant or 0
              state.last_performed_value = 0
            end

            state.save!
          end
        end
      end

      # Update Maintenance Status Cache for all plans associated with this asset
      # This runs AFTER processing meters and checks, so it will capture the latest state
      # (including resets from 'fixed' checks and increments from meter readings).
      @asset.asset_category.components.flat_map(&:sub_components).flat_map(&:maintenance_plans).each do |plan|
         MaintenanceStatusService.new(@asset, plan).update_state!
      end

      # Process Warehouse Parts & Consumptions
      parts = params[:parts] || []
      parts.each do |part_data|
        item_id = part_data[:warehouse_item_id]
        quantity = part_data[:quantity].to_f
        action_type = part_data[:action_type].presence || "exit"

        next if item_id.blank? || quantity <= 0

        warehouse_item = WarehouseItem.find(item_id)
        StockMovement.create!(
          account: current_account,
          warehouse_item: warehouse_item,
          user: current_user,
          asset: @asset,
          logbook_record: record,
          movement_type: action_type.to_sym,
          quantity: quantity,
          notes: "#{action_type == 'reserve' ? 'Reserva' : 'Instalación'} para #{@asset.name} (#{@asset.plate.presence || 'S/P'})"
        )
      end
    end

    redirect_to logbook_index_path, notice: "Bitácora actualizada correctamente."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error al guardar: #{e.record.errors.full_messages.join(', ')}"
    @meters = @asset.meters
    @structure = @asset.maintenance_structure
    @assets_for_select = Asset.all.map { |a| ["#{a.name} - #{a.plate.presence || 'S/P'}", a.id] }
    render :new, status: :unprocessable_entity
  end
end
