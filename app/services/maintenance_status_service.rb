class MaintenanceStatusService
  # Calculates the maintenance status for a given asset and plan
  # Returns a hash with status details

  STATUS_COLORS = {
    white: 'secondary', # < 50%
    yellow: 'warning',  # 50% - 74%
    orange: 'orange',   # 75% - 99%
    red: 'danger'       # >= 100%
  }

  def initialize(asset, plan)
    @asset = asset
    @plan = plan
  end

  def calculate
    # Find the corresponding meter
    meter = @asset.meters.find_by(unit: @plan.unit)

    # Find the last maintenance state
    state = @asset.maintenance_states.find_by(maintenance_plan: @plan)

    current_value = meter&.current_value || 0
    last_performed = state&.last_performed_value || 0

    # Determine if the plan is time-based
    is_time_based = ['Dias', 'Meses', 'Años'].include?(@plan.unit)

    result = if is_time_based
               calculate_time_based_status(state)
             else
               calculate_meter_based_status(current_value, last_performed)
             end

    # Return result directly. Use update_state! explicitly if you want to save.
    result
  end

  def update_state!
    # Calculate status first
    status = calculate

    # Find or Create State record
    state = MaintenanceState.find_or_initialize_by(asset: @asset, maintenance_plan: @plan)

    # Update Cached Columns
    state.current_status = status[:status]
    state.percentage_used = status[:percentage]

    # Parse target date string if present (fragile but functional for now)
    # A better way would be to return raw due_date in the hash
    # But for now, let's keep it simple.
    # Note: calculate_time_based_status does not return raw date in result hash, only formatted string.
    # We should update calculate_ methods to include :due_date raw object.
    state.next_due_at = status[:raw_due_date] if status[:raw_due_date]

    state.save!

    status
  end

  private

  def calculate_time_based_status(state)
    # Default to asset commission date (or creation if fallback) if no maintenance has been performed
    last_performed_date = state&.last_performed_at || @asset.commission_date || @asset.created_at || Date.today

    # Calculate frequency in days
    frequency_days = case @plan.unit
                     when 'Dias' then @plan.frequency
                     when 'Meses' then @plan.frequency * 30
                     when 'Años' then @plan.frequency * 365
                     else 0
                     end

    due_date = last_performed_date + frequency_days.days
    days_elapsed = (Time.current - last_performed_date).to_i / 1.day
    # Ensure non-negative elapsed time
    days_elapsed = 0 if days_elapsed < 0

    percentage = if frequency_days > 0
                   (days_elapsed.to_f / frequency_days) * 100
                 else
                   0.0
                 end

    {
      plan_name: @plan.name,
      sub_component: @plan.sub_component.name,
      frequency: @plan.frequency,
      unit: @plan.unit,
      current_usage: "#{days_elapsed} días",
      percentage: percentage.round(1),
      status: determine_status(percentage),
      color_class: determine_color(percentage),
      details: "#{days_elapsed} / #{frequency_days} Días",
      target: "Vence: #{due_date.strftime("%d/%m/%Y")}",
      raw_due_date: due_date # Added for caching
    }
  end

  def calculate_meter_based_status(current_value, last_performed)
    # Calculate usage since last maintenance
    usage = current_value - last_performed
    usage = 0 if usage < 0 # Handle potential odometer reset edge cases safely

    frequency = @plan.frequency || 0

    if frequency > 0
      percentage = (usage.to_f / frequency) * 100
    else
      percentage = 0.0
    end

    remaining = frequency - usage
    remaining = 0 if remaining < 0

    {
      plan_name: @plan.name,
      sub_component: @plan.sub_component.name,
      frequency: frequency,
      unit: @plan.unit,
      current_usage: usage,
      percentage: percentage.round(1),
      status: determine_status(percentage),
      color_class: determine_color(percentage),
      details: "#{number_with_delimiter(usage)} / #{number_with_delimiter(@plan.frequency)} #{@plan.unit}",
      target: "Restan: #{number_with_delimiter(remaining)} #{@plan.unit}"
    }
  end

  def number_with_delimiter(number)
    ActiveSupport::NumberHelper.number_to_delimited(number)
  end

  private

  def determine_status(percentage)
    if percentage >= 100
      :red
    elsif percentage >= 75
      :orange
    elsif percentage >= 50
      :yellow
    else
      :white
    end
  end

  def determine_color(percentage)
    if percentage >= 100
      'bg-danger'
    elsif percentage >= 75
      'bg-orange' # Requires custom CSS or inline style for exact orange
    elsif percentage >= 50
      'bg-warning'
    else
      'bg-success' # Use success (green) for "white/good" state in progress bars usually
    end
  end
end
