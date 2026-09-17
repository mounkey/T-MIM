class LogbookEntry < ApplicationRecord
  acts_as_tenant :account
  belongs_to :meter
  belongs_to :user
  belongs_to :logbook_record, optional: true # Optional initially to support migration of old data if needed, or transient states

  before_validation :calculate_values
  after_create :update_meter_value

  validates :current_value, numericality: { greater_than_or_equal_to: 0 }
  validate :current_value_must_be_greater_than_previous, on: :create

  private

  def calculate_values
    self.previous_value ||= meter.current_value

    if quantity.present? && current_value.blank?
      self.current_value = previous_value + quantity
    elsif current_value.present? && quantity.blank?
      self.quantity = current_value - previous_value
    elsif current_value.present? && quantity.present?
      # Ensure consistency if both are provided
      if (current_value - previous_value).abs > 0.01 && (current_value - previous_value) != quantity
         # If inconsistent, prioritize current_value
         self.quantity = current_value - previous_value
      end
    end
  end

  def current_value_must_be_greater_than_previous
    return if quantity.nil? # Handled by validations if required

    if quantity < 0
      errors.add(:current_value, "no puede ser menor que el valor anterior (#{previous_value})")
    end
  end

  def update_meter_value
    meter.update!(current_value: current_value)
  end
end
