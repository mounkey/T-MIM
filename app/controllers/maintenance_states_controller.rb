class MaintenanceStatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset_and_plan

  def new
    # Renders the modal form
  end

  def create
    # Find or initialize the state record
    state = MaintenanceState.find_or_initialize_by(
      asset: @asset,
      maintenance_plan: @plan
    )

    # Get the current meter value for this plan's unit
    meter = @asset.meters.find_by(unit: @plan.unit)
    current_value = meter&.current_value || 0

    ActiveRecord::Base.transaction do
      # 1. Update the state
      state.last_performed_value = current_value
      state.last_performed_at = Time.current
      state.save!

      # 2. Create Logbook Record (Event Header)
      logbook = LogbookRecord.create!(
        user: current_user,
        asset: @asset,
        recorded_at: Time.current,
        notes: params[:notes].presence || "Mantenimiento Realizado: #{@plan.name} - #{@plan.sub_component.name}",
        provider_id: params[:provider_id].presence,
        provider_rating: params[:provider_rating].presence
      )

      # 3. Create Logbook Entry (Detail - capturing the value at maintenance time)
      # This is optional but good for data integrity: it logs the value at which it was reset.
      if meter
        LogbookEntry.create!(
          logbook_record: logbook,
          meter: meter,
          user: current_user,
          current_value: current_value,
          remarks: "Reinicio por Regla de Mantenimiento"
        )
      end
    end

    redirect_to asset_path(@asset), notice: "Mantenimiento registrado y regla reiniciada correctamente."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to asset_path(@asset), alert: "Error al registrar mantenimiento: #{e.message}"
  end

  def edit_adjustment
    @asset = Asset.find(params[:asset_id])
    @plan = MaintenancePlan.find(params[:maintenance_plan_id])
    @state = MaintenanceState.find_or_initialize_by(asset: @asset, maintenance_plan: @plan)

    # If new, defaults are nil. We might want to show current meter value?
    # Actually, adjusting "Last Performed" means setting it to a specific value.
    # Default to 0 if nil.
    @state.last_performed_value ||= 0
  end

  def update_adjustment
    @asset = Asset.find(params[:asset_id])
    @plan = MaintenancePlan.find(params[:maintenance_plan_id])
    @state = MaintenanceState.find_or_initialize_by(asset: @asset, maintenance_plan: @plan)

    new_value = params[:maintenance_state][:last_performed_value]

    if @state.update(last_performed_value: new_value)
      redirect_to maintenance_path, notice: "Ajuste de contador actualizado correctamente."
    else
      render :edit_adjustment, status: :unprocessable_entity
    end
  end

  private

  def set_asset_and_plan
    # Only for create action which uses these params directly
    if action_name == 'create' || action_name == 'new'
      @asset = Asset.find(params[:asset_id])
      @plan = MaintenancePlan.find(params[:maintenance_plan_id])
    end
  end
end
