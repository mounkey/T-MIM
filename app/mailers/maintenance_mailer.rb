class MaintenanceMailer < ApplicationMailer
  default from: 'no-reply@mim.cl'

  def alert_email(user_email, asset, plan, status_details)
    @asset = asset
    @plan = plan
    @status = status_details
    @user_email = user_email

    mail(
      to: @user_email,
      subject: "⚠️ Alerta de Mantenimiento: #{@asset.name} - #{@plan.name}"
    )
  end
end
