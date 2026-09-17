module Multitenancy
  extend ActiveSupport::Concern

  included do
    set_current_tenant_through_filter
    before_action :set_tenant
  end

  private

  def set_tenant
    if ENV['SINGLE_TENANT_MODE'] == 'true'
      # Enterprise Mode: Always use the first/default account
      set_current_tenant(Account.first)
      return
    end

    # SaaS Mode (Multi-tenant)
    if current_user
      # VULNERABILITY #1 FIXED: If user is logged in, ALWAYS use their account.
      # This prevents Cross-Tenant Session Leaks if they change the URL subdomain.
      set_current_tenant(current_user.account)
    else
      # If not logged in, detect by subdomain (e.g. to show correct company logo on login)
      subdomain = request.subdomain
      
      # Quality of Life for local development: if no subdomain on localhost, use 'default'
      subdomain = 'default' if subdomain.blank? && Rails.env.development?
      
      current_account = Account.find_by(subdomain: subdomain)

      if current_account
        set_current_tenant(current_account)
      else
        # VULNERABILITY #2 FIXED: Do not fallback to Account.first on an invalid subdomain.
        raise ActiveRecord::RecordNotFound, "Company not found"
      end
    end
  end
end
