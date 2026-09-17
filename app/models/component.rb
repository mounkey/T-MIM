class Component < ApplicationRecord
  acts_as_tenant :account
  belongs_to :asset_category
  has_many :sub_components, dependent: :destroy
  accepts_nested_attributes_for :sub_components, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: { scope: :asset_category_id, case_sensitive: false }
end
