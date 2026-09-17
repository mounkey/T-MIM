class MaintenanceSummaryMailer < ApplicationMailer
  default from: 'no-reply@mim.cl'

  def daily_summary_email(user_email, critical_assets, warning_assets)
    @critical_assets = critical_assets
    @warning_assets = warning_assets
    @user_email = user_email

    # Calculate totals for subject line
    total_alerts = @critical_assets.count + @warning_assets.count

    mail(
      to: @user_email,
      subject: "📊 Resumen Diario de Mantenimiento: #{total_alerts} alertas pendientes"
    )
  end
end
