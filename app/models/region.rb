class Region < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
