class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset, only: [:vehicle_latest_repair, :vehicle_full_history]

  # Hub Central de Reportes
  def index
    @assets = Asset.includes(:client, :asset_category).order(:name)
    @total_assets_count = @assets.count
    @total_items_count = WarehouseItem.count
    @low_stock_count = WarehouseItem.where("stock_quantity <= minimum_stock").count
    @inventory_cost_total = WarehouseItem.sum("stock_quantity * cost_price")
    @inventory_sale_total = WarehouseItem.sum("stock_quantity * sale_price")
  end

  # 1. Reporte de Inventario y Bodega (Valorización y Stock Crítico)
  def inventory
    @account = current_user.account
    @warehouse_items = WarehouseItem.all.order(:category, :name)

    # Filtros
    if params[:category].present?
      @warehouse_items = @warehouse_items.where(category: params[:category])
    end

    if params[:stock_status] == "low_stock"
      @warehouse_items = @warehouse_items.where("stock_quantity <= minimum_stock AND stock_quantity > 0")
    elsif params[:stock_status] == "out_of_stock"
      @warehouse_items = @warehouse_items.where("stock_quantity <= 0")
    elsif params[:stock_status] == "optimal"
      @warehouse_items = @warehouse_items.where("stock_quantity > minimum_stock")
    end

    # Métricas y valorizaciones
    allItems = WarehouseItem.all
    @total_skus = allItems.count
    @total_units = allItems.sum(:stock_quantity)
    @total_reserved_units = allItems.sum(:reserved_quantity)
    @total_available_units = [allItems.sum(:stock_quantity) - allItems.sum(:reserved_quantity), 0].max
    @total_cost_valuation = allItems.sum("stock_quantity * cost_price")
    @total_sale_valuation = allItems.sum("stock_quantity * sale_price")
    @estimated_profit = @total_sale_valuation - @total_cost_valuation
    @low_stock_count = allItems.where("stock_quantity <= minimum_stock AND stock_quantity > 0").count
    @out_of_stock_count = allItems.where("stock_quantity <= 0").count

    # Últimos movimientos de Kardex
    @recent_movements = StockMovement.includes(:warehouse_item, :user, :asset)
                                     .order(created_at: :desc)
                                     .limit(10)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "reports/inventory_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "informe_inventario_#{Date.today.strftime('%Y%m%d')}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # 2. Reporte de Última Reparación / Reparación Actual del Vehículo
  def vehicle_latest_repair
    @account = current_user.account
    @payment_order = @asset.payment_orders.order(created_at: :desc).first
    @logbook_record = @asset.logbook_records.order(recorded_at: :desc).first

    # Repuestos e insumos vinculados a la última intervención
    @parts_used = if @payment_order&.logbook_record
                    @payment_order.logbook_record.stock_movements.where(movement_type: :exit).includes(:warehouse_item)
                  elsif @logbook_record
                    @logbook_record.stock_movements.where(movement_type: :exit).includes(:warehouse_item)
                  else
                    @asset.stock_movements.where(movement_type: :exit).order(created_at: :desc).limit(10).includes(:warehouse_item)
                  end

    # Tareas o checks de mantenimiento realizados
    @maintenance_checks = @logbook_record&.maintenance_checks&.includes(:component, :sub_component) || []

    # Abonos y pagos asociados a la OT actual
    @payments = @payment_order&.payments&.order(recorded_at: :desc) || []

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "reports/vehicle_latest_repair_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        filename = "reparacion_actual_#{@asset.plate.presence || @asset.id}_#{Date.today.strftime('%Y%m%d')}.pdf"
        send_data pdf, filename: filename, type: "application/pdf", disposition: "inline"
      end
    end
  end

  # 3. Reporte de Historial Completo de Vida del Vehículo
  def vehicle_full_history
    @account = current_user.account
    @logbook_records = @asset.logbook_records
                             .includes(:user, :provider, :maintenance_checks, :stock_movements, logbook_entries: :meter)
                             .order(recorded_at: :desc)
    @payment_orders = @asset.payment_orders.includes(:payments).order(created_at: :desc)

    @total_interventions = @logbook_records.count
    @total_spent = @payment_orders.sum(:total_amount)
    @total_paid = Payment.where(payment_order_id: @payment_orders.pluck(:id)).sum(:amount)
    @total_parts_count = @asset.stock_movements.where(movement_type: :exit).sum(:quantity)

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "reports/vehicle_full_history_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        filename = "historial_completo_#{@asset.plate.presence || @asset.id}_#{Date.today.strftime('%Y%m%d')}.pdf"
        send_data pdf, filename: filename, type: "application/pdf", disposition: "inline"
      end
    end
  end

  # Proyecciones de Mantenimiento Preventivo
  def maintenance_projection
    @projections = []

    assets = Asset.includes(:meters, maintenance_states: :maintenance_plan)
                  .where(status: :operativa)

    assets.each do |asset|
      adus = {}
      days_active = (Date.today - (asset.commission_date || asset.created_at.to_date)).to_f
      days_active = 1.0 if days_active < 1

      asset.meters.each do |meter|
        adus[meter.unit] = meter.current_value / days_active
      end

      asset.maintenance_states.each do |state|
        plan = state.maintenance_plan
        next unless plan

        due_date = nil
        remaining_days = nil

        if plan.unit.in?(["Días", "Semanas", "Meses"])
           last_date = state.last_performed_at&.to_date || asset.commission_date || Date.today
           days_interval = case plan.unit
                           when "Días" then plan.frequency
                           when "Semanas" then plan.frequency * 7
                           when "Meses" then plan.frequency * 30
                           end
           due_date = last_date + days_interval.days
           remaining_days = (due_date - Date.today).to_i

        elsif adu = adus[plan.unit]
           last_val = state.last_performed_value || 0
           target_val = last_val + plan.frequency

           current_meter = asset.meters.find { |m| m.unit == plan.unit }
           current_val = current_meter&.current_value || 0

           remaining_val = target_val - current_val

           if adu > 0
             days_to_go = remaining_val / adu
             due_date = Date.today + days_to_go.days
             remaining_days = days_to_go.to_i
           else
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

    @projections.sort_by! { |p| p[:due_date] }

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "reports/maintenance_projection", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "proyeccion_mantenimiento_#{Date.today}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end
end
