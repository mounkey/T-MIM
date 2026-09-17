class ReportsController < ApplicationController
  before_action :authenticate_user!

  def maintenance_projection
    # Strategy:
    # 1. Fetch all active Assets with Maintenance Plans.
    # 2. For each plan, calculate Average Daily Usage (ADU) of the asset.
    # 3. Predict due date: Next Due Date = Today + (Remaining Value / ADU).
    # 4. Filter for next 30/60 days.

    @projections = []

    # Eager load everything needed
    assets = Asset.includes(:meters, maintenance_states: :maintenance_plan)
                  .where(status: :operativa)

    assets.each do |asset|
      # Calculate ADU for each meter type (KM, Hours)
      # ADU = Total Usage / Days since commission

      adus = {}
      days_active = (Date.today - (asset.commission_date || asset.created_at.to_date)).to_f
      days_active = 1.0 if days_active < 1

      asset.meters.each do |meter|
        # Initial value is assumed 0 for calculation simplicity, or we should track it.
        # Current Value / Days
        adus[meter.unit] = meter.current_value / days_active
      end

      asset.maintenance_states.each do |state|
        plan = state.maintenance_plan
        next unless plan

        # Determine Due Date
        due_date = nil
        remaining_days = nil

        if plan.unit.in?(["Días", "Semanas", "Meses"])
           # Time based is easy, it's already in next_due_at usually (if Service calc is correct)
           # Or we calculate: Last Performed + Frequency
           last_date = state.last_performed_at&.to_date || asset.commission_date || Date.today
           days_interval = case plan.unit
                           when "Días" then plan.frequency
                           when "Semanas" then plan.frequency * 7
                           when "Meses" then plan.frequency * 30
                           end
           due_date = last_date + days_interval.days
           remaining_days = (due_date - Date.today).to_i

        elsif adu = adus[plan.unit]
           # Meter based
           # Remaining Value = (Last Value + Frequency) - Current Value
           # Actually MaintenanceState doesn't store "Target Value". It stores "Percentage".
           # We need to recalculate:
           last_val = state.last_performed_value || 0
           target_val = last_val + plan.frequency

           # Find current meter value
           current_meter = asset.meters.find { |m| m.unit == plan.unit }
           current_val = current_meter&.current_value || 0

           remaining_val = target_val - current_val

           if adu > 0
             days_to_go = remaining_val / adu
             due_date = Date.today + days_to_go.days
             remaining_days = days_to_go.to_i
           else
             # No usage? Infinite.
             due_date = nil
           end
        end

        if due_date && due_date <= 60.days.from_now
           @projections << {
             asset: asset,
             plan: plan,
             due_date: due_date,
             remaining_days: remaining_days,
             status: remaining_days < 0 ? :overdue : (remaining_days < 7 ? :urgent : :upcoming)
           }
        end
      end
    end

    # Sort by due date
    @projections.sort_by! { |p| p[:due_date] }

    respond_to do |format|
      format.pdf do
        html = render_to_string(template: "reports/maintenance_projection", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "proyeccion_mantenimiento_#{Date.today}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end
end
