class ApplicationController < ActionController::Base
  include Multitenancy

  # Only allow modern browsers supporting webp, images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :run])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :run])
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
