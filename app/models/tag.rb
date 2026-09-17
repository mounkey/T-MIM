class Tag < ApplicationRecord
  acts_as_tenant :account
  validates :name, presence: true, uniqueness: true

  # Default color if none provided
  after_initialize :set_default_color, if: :new_record?

  private

  def set_default_color
    self.color ||= "#041C36" # Default Dark Blue
  end
end
