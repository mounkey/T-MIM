class CapacityMailer < ApplicationMailer
  default from: "alertas@t-mim.cl"

  def capacity_warning_email(account, recipient_email)
    @account = account
    @percentage = @account.capacity_percentage
    @limit = @account.effective_assets_limit
    @current_count = @account.assets.count

    subject = if @percentage >= 100
                "⚠️ [URGENTE T-MIM] Capacidad 100% Alcanzada en #{@account.name} - Bloqueo de Vehículos"
              else
                "🔔 [AVISO T-MIM] Alerta de Capacidad al 95% en #{@account.name}"
              end

    mail(to: recipient_email, subject: subject)
  end
end
