module Superadmin
  class BaseController < ApplicationController
    before_action :authenticate_super_admin!
    
    # We must completely bypass ActsAsTenant in the Superadmin namespace!
    around_action :bypass_tenant

    layout 'superadmin'

    private

    def bypass_tenant
      ActsAsTenant.without_tenant do
        yield
      end
    end
  end
end
