class RemittanceBatch < ApplicationRecord
  validates :batch_code, :period_start, :period_end, presence: true
  validates :batch_code, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }
end
