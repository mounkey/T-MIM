class ApplicationController < ActionController::Base
  include Multitenancy

  # Only allow modern browsers supporting webp, images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :run ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :run ])
  end

  # Plan permission guards
  def ensure_warehouse_access!
    return if current_user&.account&.can_access_warehouse?
    flash[:alert] = "El módulo de Bodega e Inventario no está disponible en su plan actual (#{current_user&.account&.plan_type&.humanize || 'Inicial'}). Para habilitar Kardex y stock, mejore al Plan Estándar o superior."
    redirect_to authenticated_root_path
  end

  def ensure_maintenance_access!
    return if current_user&.account&.can_access_maintenance?
    flash[:alert] = "El módulo de Planes y Matrices Preventivas no está disponible en su plan actual (#{current_user&.account&.plan_type&.humanize || 'Inicial'}). Mejore al Plan Estándar o superior para habilitarlo."
    redirect_to authenticated_root_path
  end

  def ensure_finances_access!
    return if current_user&.account&.can_access_finances?
    flash[:alert] = "El módulo de Finanzas, Presupuestos y Órdenes de Trabajo requiere Plan Pro o Full. Su plan actual es #{current_user&.account&.plan_type&.humanize || 'Inicial'}."
    redirect_to authenticated_root_path
  end

  def ensure_flow_payments_access!
    return if current_user&.account&.can_access_flow_payments?
    flash[:alert] = "La recaudación online y liquidaciones automáticas Flow están reservadas para el Plan Full o Gran Taller."
    redirect_to finances_path
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      UserLoginHistory.create!(
        user: resource,
        account: resource.account,
        sign_in_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    if resource.is_a?(SuperAdmin)
      superadmin_dashboard_index_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    # Resource can be nil or symbol on sign out
    if resource_or_scope == :user || resource_or_scope.is_a?(User)
      user = current_user
      if user
        last_login = UserLoginHistory.where(user: user).order(sign_in_at: :desc).first
        last_login&.update(sign_out_at: Time.current)
      end
    end
    super
  end
end
