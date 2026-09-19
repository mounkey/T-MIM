class PaymentOrder < ApplicationRecord
  acts_as_tenant :account

  belongs_to :client, optional: true
  belongs_to :asset, optional: true
  belongs_to :logbook_record, optional: true

  has_many :payments, dependent: :destroy
  has_many :stock_movements, through: :logbook_record

  enum :mechanical_status, {
    diagnosis: 0,
    in_progress: 1,
    completed: 2,
    delivered: 3
  }

  before_validation :generate_folio_and_token, on: :create
  before_save :recalculate_total

  validates :folio_number, presence: true, uniqueness: { scope: :account_id }
  validates :payment_token, presence: true, uniqueness: true

  # Totales y Estados Financieros Calculados
  def total_paid
    payments.sum(:amount)
  end

  def balance_due
    [total_amount - total_paid, 0].max
  end

  def financial_status
    paid = total_paid
    total = total_amount

    if paid <= 0
      :unpaid
    elsif paid >= total && total > 0
      :paid
    else
      :partial
    end
  end

  def financial_status_badge
    case financial_status
    when :paid
      { label: "Pagado Total", class: "bg-success text-white" }
    when :partial
      { label: "Abonado", class: "bg-warning text-dark" }
    when :unpaid
      { label: "Sin Pago", class: "bg-danger text-white" }
    end
  end

  def mechanical_status_badge
    case mechanical_status.to_sym
    when :diagnosis
      { label: "Diagnóstico", class: "bg-info text-dark" }
    when :in_progress
      { label: "En Reparación", class: "bg-primary text-white" }
    when :completed
      { label: "Trabajo Finalizado", class: "bg-warning text-dark" }
    when :delivered
      { label: "Entregado", class: "bg-success text-white" }
    end
  end

  # Sincronización con Repuestos de Bodega
  def update_parts_amount_from_logbook!
    return unless logbook_record

    # Suma los repuestos utilizados en el logbook_record
    calculated_parts = logbook_record.stock_movements.where(movement_type: :exit).includes(:warehouse_item).sum do |movement|
      movement.quantity * (movement.warehouse_item&.sale_price || 0)
    end

    self.parts_amount = calculated_parts
    recalculate_total
    save!
  end

  private

  def generate_folio_and_token
    self.payment_token ||= SecureRandom.urlsafe_base64(24)
    if folio_number.blank?
      last_folio = account.payment_orders.maximum(:created_at)
      count = account.payment_orders.count + 1
      self.folio_number = "OT-%04d" % count
    end
  end

  def recalculate_total
    self.labor_amount ||= 0.0
    self.parts_amount ||= 0.0
    self.discount_amount ||= 0.0
    self.total_amount = [self.labor_amount + self.parts_amount - self.discount_amount, 0].max
  end
end
