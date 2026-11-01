class AddExtraQuotaAndNotificationTrackingToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :extra_assets_quota, :integer, default: 0, null: false
    add_column :accounts, :last_capacity_warning_sent_at, :datetime
  end
end
