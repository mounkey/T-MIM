module Superadmin
  class SettlementsController < BaseController
    before_action :set_settlement, only: [:show, :mark_as_paid]

    def index
      @settlements = Settlement.includes(:account).order(created_at: :desc)
      
      # Cálculos globales para Superadmin
      @total_flow_collected = Payment.where(payment_channel: :flow_online).sum(:amount)
      @total_platform_earnings = Payment.where(payment_channel: :flow_online).sum(:platform_fee)
      @pending_payouts_total = Settlement.where(status: :pending).sum(:net_payout)

      # Cuentas con saldo Flow pendiente por liquidar
      @unsettled_accounts = Account.joins(:payments)
                                   .where(payments: { payment_channel: :flow_online, settlement_id: nil })
                                   .distinct
    end

    def show
      @payments = @settlement.payments.includes(:payment_order)
    end

    def new
      @settlement = Settlement.new
      @accounts = Account.all.order(:name)
      @default_start = 15.days.ago.to_date
      @default_end = Date.today
    end

    def create
      account = Account.find(params[:settlement][:account_id])
      start_date = params[:settlement][:period_start].to_date
      end_date = params[:settlement][:period_end].to_date

      # Buscar todos los pagos Flow no liquidados en ese rango de fechas
      unsettled_payments = account.payments.where(payment_channel: :flow_online, settlement_id: nil)
                                           .where("recorded_at >= ? AND recorded_at <= ?", start_date.beginning_of_day, end_date.end_of_day)

      if unsettled_payments.empty?
        redirect_to new_superadmin_settlement_path, alert: "No hay pagos de Flow pendientes para este taller en el rango seleccionado."
        return
      end

      total_coll = unsettled_payments.sum(:amount)
      total_gw = unsettled_payments.sum(:flow_fee)
      total_plat = unsettled_payments.sum(:platform_fee)
      net_pay = unsettled_payments.sum(:net_amount)

      bank_info = "Banco: #{account.bank_name || 'N/A'} | Tipo: #{account.bank_account_type || 'N/A'} | N°: #{account.bank_account_number || 'N/A'} | Titular: #{account.bank_account_holder_name || account.name} | RUT: #{account.bank_account_holder_rut || account.rut}"

      ActiveRecord::Base.transaction do
        @settlement = Settlement.create!(
          account: account,
          period_start: start_date,
          period_end: end_date,
          total_collected: total_coll,
          total_gateway_fees: total_gw,
          total_platform_fees: total_plat,
          net_payout: net_pay,
          status: :pending,
          bank_details_snapshot: bank_info,
          notes: params[:settlement][:notes]
        )

        unsettled_payments.update_all(settlement_id: @settlement.id)
      end

      redirect_to superadmin_settlement_path(@settlement), notice: "Corte quincenal generado con éxito (Folio: #{@settlement.folio})."
    end

    def mark_as_paid
      @settlement.update!(
        status: :paid,
        transferred_at: Time.current,
        transfer_reference: params[:transfer_reference]
      )
      redirect_to superadmin_settlement_path(@settlement), notice: "Liquidación marcada como TRANSFERIDA / PAGADA."
    end

    private

    def set_settlement
      @settlement = Settlement.find(params[:id])
    end
  end
end
