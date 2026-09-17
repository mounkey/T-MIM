class MaintenanceState < ApplicationRecord
  acts_as_tenant :account
  belongs_to :asset
  belongs_to :maintenance_plan

  # Enum for cached status
  enum :current_status, { white: 0, yellow: 1, orange: 2, red: 3 }, default: :white
end
