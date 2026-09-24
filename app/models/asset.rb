class Asset < ApplicationRecord
  acts_as_tenant :account

  belongs_to :asset_category
  belongs_to :tag
  belongs_to :client, optional: true
  has_many :meters, dependent: :destroy
  has_many :logbook_records, dependent: :destroy
  has_many :maintenance_states, dependent: :destroy
  has_many :payment_orders, dependent: :nullify
  has_many :stock_movements, dependent: :nullify

  validates :name, presence: true
  validates :status, presence: true

  # 0: Operativa, 1: En Mantención, 2: Fuera de Servicio
  enum :status, { operativa: 0, en_mantencion: 1, fuera_de_servicio: 2 }, default: :operativa

  before_save :set_default_commission_date

  def status_label
    status.to_s.humanize
  end

  def maintenance_structure
    asset_category.components.includes(:sub_components)
  end

  def latest_payment_order
    payment_orders.order(created_at: :desc).first
  end

  def latest_logbook_record
    logbook_records.order(recorded_at: :desc).first
  end

  def total_spent_on_repairs
    payment_orders.sum(:total_amount)
  end

  def total_parts_used_count
    stock_movements.where(movement_type: :exit).sum(:quantity)
  end

  private

  def set_default_commission_date
    self.commission_date ||= created_at&.to_date || Date.today
  end
end
