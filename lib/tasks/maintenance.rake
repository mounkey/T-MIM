namespace :maintenance do
  desc "Check maintenance status for all assets and send daily summary email to admins"
  task daily_check: :environment do
    Rails.logger.info "Starting daily maintenance check..."

    # Optimization: We check assets once, then distribute to admins.
    # In a multi-tenant system, we would scope by tenant/organization.
    # Here, we assume all admins oversee all assets.

    critical_assets = []
    warning_assets = []

    Asset.find_each do |asset|
      # Get all plans for the asset via its structure
      # We need to traverse: Asset -> AssetCategory -> Components -> SubComponents -> MaintenancePlans
      # And verify against MaintenanceStates or Logs

      # Using a simplified approach: Iterate all plans applicable to this asset's category
      plans = asset.asset_category.components.flat_map(&:sub_components).flat_map(&:maintenance_plans)

      plans.each do |plan|
        service = MaintenanceStatusService.new(asset, plan)
        # Calculate AND Persist status to DB for dashboard optimization
        status = service.update_state!

        item = { asset: asset, plan: plan, status: status }

        if status[:status] == :red
          critical_assets << item
        elsif status[:status] == :orange
          warning_assets << item
        end
      end
    end

    if critical_assets.any? || warning_assets.any?
      Rails.logger.info "Found #{critical_assets.count} critical and #{warning_assets.count} warning items. Sending emails..."

      User.where(role: 'admin').find_each do |admin|
        MaintenanceSummaryMailer.daily_summary_email(admin.email, critical_assets, warning_assets).deliver_now
        Rails.logger.info "Email sent to #{admin.email}"
      end
    else
      Rails.logger.info "No maintenance alerts found today."
    end

    Rails.logger.info "Daily maintenance check completed."
  end
end
