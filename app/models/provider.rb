class Provider < ApplicationRecord
  acts_as_tenant :account

  belongs_to :region
  belongs_to :city
  has_and_belongs_to_many :tags
  has_many :logbook_records

  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :account_id }

  # Default values
  after_initialize :set_defaults, if: :new_record?

  # Normalize website URL
  before_save :normalize_website

  private

  def set_defaults
    self.active = true if active.nil?
    self.rating ||= 0
  end

  def normalize_website
    return if website.blank?

    unless website.match?(/\Ahttps?:\/\//)
      self.website = "https://#{website}"
    end
  end
end
