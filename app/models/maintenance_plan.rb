class MaintenancePlan < ApplicationRecord
  acts_as_tenant :account
  belongs_to :sub_component, optional: true
  belongs_to :asset_category, optional: true

  validates :name, presence: true
  validates :frequency, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
end
