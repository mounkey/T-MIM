class OnboardingController < ApplicationController
  skip_before_action :set_tenant, raise: false
  layout "landing"

  before_action :set_account_by_token

  def show
    if @account.invitation_expired?
      render :expired and return
    end

    if @account.contract_accepted?
      redirect_to new_user_session_path, notice: "El contrato ya ha sido aceptado anteriormente. Ingrese con sus credenciales de taller."
      return
    end
  end

  def accept_contract
    if @account.invitation_expired?
      render :expired and return
    end

    legal_rut = params[:legal_representative_rut].presence || @account.legal_representative_rut.presence || @account.rut

    # Validar contraseña provisoria
    if params[:primary_password].present?
      unless params[:primary_password].strip == @account.temporary_password.to_s.strip
        flash.now[:alert] = "La contraseña provisoria no es correcta. Revise el correo de invitación enviado por T-MIM."
        render :show, status: :unprocessable_entity and return
      end
    end

    @account.accept_contract!(
      ip_address: request.remote_ip,
      representative_rut: legal_rut
    )

    if @account.flow_billing?
      redirect_to account_payment_path(token: @account.invitation_token), notice: "Contrato formalizado con éxito. Por favor continúe con el enrolamiento automático en Flow."
    else
      redirect_to account_final_security_path(token: @account.invitation_token), notice: "Contrato formalizado bajo acuerdo directo. Por su seguridad, defina ahora su contraseña definitiva."
    end
  end

  def payment
    if @account.manual_billing?
      redirect_to account_final_security_path(token: @account.invitation_token)
      return
    end
  end

  def complete_payment
    redirect_to account_final_security_path(token: @account.invitation_token), notice: "¡Enrolamiento y suscripción Flow registrada con éxito! Por su seguridad, defina ahora su contraseña personal y definitiva."
  end

  def final_security
  end

  def set_final_password
    new_password = params[:password].to_s.strip
    password_confirmation = params[:password_confirmation].to_s.strip

    if new_password.length < 8
      flash.now[:alert] = "La contraseña definitiva debe tener al menos 8 caracteres."
      render :final_security, status: :unprocessable_entity and return
    end

    if new_password != password_confirmation
      flash.now[:alert] = "La confirmación de la contraseña no coincide."
      render :final_security, status: :unprocessable_entity and return
    end

    @account.complete_onboarding_and_set_password!(new_password)

    redirect_to new_user_session_path, notice: "¡Contraseña definitiva configurada con éxito! Su taller está 100% activo. Ya puede iniciar sesión."
  end

  private

  def set_account_by_token
    @account = Account.find_by!(invitation_token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render :not_found, status: :not_found
  end
end
