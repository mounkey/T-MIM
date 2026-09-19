class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :asset_categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :providers, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :maintenance_plans, dependent: :destroy
  has_many :maintenance_states, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :payment_orders, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :settlements, dependent: :destroy

  belongs_to :region, optional: true
  belongs_to :city, optional: true

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
end
