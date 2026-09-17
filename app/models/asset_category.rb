class AssetCategory < ApplicationRecord
  acts_as_tenant :account

  has_many :assets
  has_many :components, dependent: :destroy
  has_many :maintenance_plans, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :account_id }

  accepts_nested_attributes_for :components, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :maintenance_plans, allow_destroy: true, reject_if: :all_blank

  def maintenance_structure
    components.includes(:sub_components)
  end
end
