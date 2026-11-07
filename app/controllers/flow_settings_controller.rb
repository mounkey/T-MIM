class FlowSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_flow_payments_access!

  def show
    @account = current_user.account
  end

  def update
    @account = current_user.account

    permitted_params = params.require(:account).permit(
      :flow_integration_mode,
      :custom_flow_api_key,
      :custom_flow_secret_key
    )

    # Si elige modo delegado, limpiamos las llaves por seguridad
    if permitted_params[:flow_integration_mode] == "delegated"
      permitted_params[:custom_flow_api_key] = nil
      permitted_params[:custom_flow_secret_key] = nil
    end

    if @account.update(permitted_params)
      redirect_to flow_settings_path, notice: "Configuración de pasarela Flow actualizada correctamente."
    else
      render :show, status: :unprocessable_entity
    end
  end
end
