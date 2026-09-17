class SubComponent < ApplicationRecord
  acts_as_tenant :account
  belongs_to :component
  has_many :maintenance_plans, dependent: :destroy
  accepts_nested_attributes_for :maintenance_plans, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: { scope: :component_id, case_sensitive: false }
end
