class LandingController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "landing"

  def index
    # Redirigir si ya tiene sesión iniciada
    if user_signed_in?
      redirect_to authenticated_root_path and return
    elsif super_admin_signed_in?
      redirect_to superadmin_dashboard_index_path and return
    end

    @plans = Account::PLANS
  end

  def request_plan
    # Recepción del formulario público de solicitud de alta de taller
    plan_key = params[:plan_type].presence || "inicial"
    plan_info = Account::PLANS[plan_key] || Account::PLANS["inicial"]

    # Validar modo de pago permitido según el plan
    requested_mode = params[:billing_mode]
    if ["inicial", "estandar", "pro"].include?(plan_key)
      # Los 3 primeros planes obligatoriamente son Flow
      requested_mode = "flow"
    elsif requested_mode != "transfer"
      requested_mode = "flow"
    end

    # Crear cuenta en estado pending_activation para aprobación de SuperAdmin
    name_clean = params[:taller_name].to_s.strip
    subdomain_candidate = name_clean.parameterize.presence || "taller-#{SecureRandom.hex(3)}"
    
    # Asegurar subdominio único
    counter = 1
    base_subdomain = subdomain_candidate
    while Account.exists?(subdomain: subdomain_candidate)
      subdomain_candidate = "#{base_subdomain}#{counter}"
      counter += 1
    end

    account = Account.new(
      name: name_clean,
      razon_social: params[:razon_social].presence || name_clean,
      rut: params[:rut],
      subdomain: subdomain_candidate,
      email: params[:email],
      contacto_nombre: params[:contacto_nombre],
      contacto_telefono: params[:telefono],
      direccion: params[:direccion],
      plan_type: plan_key,
      monthly_price_uf: plan_info[:price_uf] || 0.0,
      max_assets_limit: params[:billing_cycle] == "annual" ? plan_info[:annual_limit] : plan_info[:limit],
      billing_cycle: params[:billing_cycle] == "annual" ? "annual" : "monthly",
      billing_mode: requested_mode,
      contract_status: "pending_activation"
    )

    if account.save
      account.generate_invitation_token!
      flash[:notice] = "¡Excelente! Hemos recibido tu solicitud para #{plan_info[:name]}. Nuestro equipo revisará los datos y te enviaremos tu enlace de activación por correo en breve."
      redirect_to root_path(anchor: "gracias")
    else
      flash[:alert] = "Hubo un problema al enviar tu solicitud: #{account.errors.full_messages.join(', ')}"
      redirect_to root_path(anchor: "contratar", plan: plan_key)
    end
  end
end
