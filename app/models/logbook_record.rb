class LogbookRecord < ApplicationRecord
  acts_as_tenant :account

  belongs_to :asset
  belongs_to :user
  belongs_to :provider, optional: true

  has_many :logbook_entries, dependent: :destroy
  has_many :maintenance_checks, dependent: :destroy
  has_many :stock_movements, dependent: :nullify

  validates :recorded_at, presence: true
end
