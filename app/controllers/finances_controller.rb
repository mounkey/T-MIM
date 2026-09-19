class FinancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment_order, only: [:show, :edit, :update, :parts_detail, :add_payment, :finish_work, :print_pdf]

  def index
    @orders = PaymentOrder.includes(:client, :asset, :payments, :logbook_record)
                          .order(created_at: :desc)

    # Filtros
    if params[:channel] == "flow"
      @orders = @orders.joins(:payments).where(payments: { payment_channel: :flow_online }).distinct
    elsif params[:channel] == "local"
      @orders = @orders.joins(:payments).where(payments: { payment_channel: [:cash, :pos_local, :transfer_local] }).distinct
    end

    if params[:status] == "paid"
      @orders = @orders.select { |o| o.financial_status == :paid }
    elsif params[:status] == "partial"
      @orders = @orders.select { |o| o.financial_status == :partial }
    elsif params[:status] == "unpaid"
      @orders = @orders.select { |o| o.financial_status == :unpaid }
    end

    # KPIs superiores del mes actual
    start_of_month = Time.current.beginning_of_month
    @monthly_payments = Payment.where("recorded_at >= ?", start_of_month)

    @total_sales = @monthly_payments.sum(:amount)
    @total_commission = @monthly_payments.where(payment_channel: :flow_online).sum("flow_fee + platform_fee")
    @net_to_receive = @monthly_payments.where(payment_channel: :flow_online).sum(:net_amount)
  end

  def show
    @payments = @payment_order.payments.order(recorded_at: :desc)
  end

  # Vista de Liquidaciones Quincenales para el Taller
  def liquidaciones
    account = current_user.account
    @settlements = account.settlements.order(created_at: :desc)
    @pending_balance = account.payments.where(payment_channel: :flow_online, settlement_id: nil).sum(:net_amount)
  end

  def show_liquidacion
    account = current_user.account
    @settlement = account.settlements.find(params[:settlement_id])
    @payments = @settlement.payments.includes(:payment_order)
  end

  def new
    @payment_order = PaymentOrder.new
    @assets = Asset.order(:name)
    @warehouse_items = WarehouseItem.where("stock_quantity > 0").order(:name)
  end

  def create
    @payment_order = PaymentOrder.new(payment_order_params)
    @payment_order.client = @payment_order.asset&.client if @payment_order.asset

    if @payment_order.save
      # Si se ingresó un pago inicial presencial
      if params[:initial_payment_amount].to_f > 0
        @payment_order.payments.create!(
          user: current_user,
          amount: params[:initial_payment_amount].to_f,
          payment_channel: params[:initial_payment_channel] || :cash,
          recorded_at: Time.current,
          notes: "Pago / Abono Inicial en Caja"
        )
      end

      # Si se agregaron repuestos manuales directamente en la venta
      if params[:parts].present?
        parts_sum = 0
        params[:parts].each do |part|
          next if part[:warehouse_item_id].blank? || part[:quantity].to_f <= 0

          item = WarehouseItem.find(part[:warehouse_item_id])
          qty = part[:quantity].to_f
          item.stock_movements.create!(
            user: current_user,
            movement_type: :exit,
            quantity: qty,
            asset: @payment_order.asset,
            notes: "Venta directa en Finanzas - Folio #{@payment_order.folio_number}"
          )
          parts_sum += qty * (item.sale_price || 0)
        end
        @payment_order.update!(parts_amount: parts_sum)
      end

      redirect_to finances_path, notice: "Venta registrada con éxito (Folio: #{@payment_order.folio_number})."
    else
      @assets = Asset.order(:name)
      @warehouse_items = WarehouseItem.where("stock_quantity > 0").order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @assets = Asset.order(:name)
  end

  def update
    if @payment_order.update(payment_order_params)
      redirect_to finances_path, notice: "Orden de venta actualizada correctamente."
    else
      @assets = Asset.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # Modal interactivo con doble clic en Repuestos
  def parts_detail
    @movements = if @payment_order.logbook_record
                   @payment_order.logbook_record.stock_movements.includes(:warehouse_item)
                 else
                   StockMovement.where(asset: @payment_order.asset).where("notes LIKE ?", "%#{@payment_order.folio_number}%").includes(:warehouse_item)
                 end
    render layout: false
  end

  # Registrar nuevo abono o saldo
  def add_payment
    payment = @payment_order.payments.build(
      user: current_user,
      amount: params[:amount].to_f,
      payment_channel: params[:payment_channel],
      notes: params[:notes],
      recorded_at: Time.current
    )

    if payment.save
      redirect_to finances_path, notice: "Abono de $#{view_context.number_with_delimiter(payment.amount.to_i)} registrado correctamente."
    else
      redirect_to finances_path, alert: "Error al registrar abono: #{payment.errors.full_messages.join(', ')}"
    end
  end

  # Botón Finalizar Trabajo
  def finish_work
    @payment_order.completed!
    redirect_to finances_path, notice: "Trabajo marcado como FINALIZADO. Estado financiero actualizado."
  end

  # Generar Comprobante PDF con Grover
  def print_pdf
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: "finances/print_pdf", layout: "pdf", formats: [:html]).force_encoding("UTF-8")
        pdf = Grover.new(html, display_url: request.base_url).to_pdf
        send_data pdf, filename: "comprobante_#{@payment_order.folio_number}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private

  def set_payment_order
    @payment_order = PaymentOrder.find(params[:id])
  end

  def payment_order_params
    params.require(:payment_order).permit(:asset_id, :client_id, :labor_amount, :parts_amount, :discount_amount, :mechanical_status, :notes)
  end
end
