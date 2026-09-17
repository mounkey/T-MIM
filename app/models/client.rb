class Client < ApplicationRecord
  acts_as_tenant :account

  has_many :assets, dependent: :nullify
  
  validates :name, presence: true
  
  def display_name
    rut.present? ? "#{name} (#{rut})" : name
  end
end
