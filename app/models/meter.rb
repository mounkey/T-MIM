class Meter < ApplicationRecord
  acts_as_tenant :account
  belongs_to :asset
  has_many :logbook_entries, dependent: :destroy

  validates :name, presence: true
  validates :unit, presence: true
  validates :current_value, numericality: { greater_than_or_equal_to: 0 }
end
