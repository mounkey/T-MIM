class SuperAdmin < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :region, optional: true
  belongs_to :city, optional: true
end
