class City < ApplicationRecord
  belongs_to :region

  validates :name, presence: true
end
