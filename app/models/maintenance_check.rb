class MaintenanceCheck < ApplicationRecord
  acts_as_tenant :account
  belongs_to :logbook_record
  belongs_to :component
  belongs_to :sub_component

  enum :status, { ok: 0, issue: 1, fixed: 2 }, default: :ok

  validates :status, presence: true
end
