class Settlement < ApplicationRecord
  belongs_to :account
  has_many :payments, dependent: :nullify

  enum :status, {
    pending: 0,
    paid: 1,
    canceled: 2
  }

  validates :period_start, :period_end, presence: true

  def status_badge
    case status.to_sym
    when :paid
      { label: "Transferido", class: "bg-success text-white" }
    when :pending
      { label: "Pendiente de Pago", class: "bg-warning text-dark" }
    when :canceled
      { label: "Anulada", class: "bg-secondary text-white" }
    end
  end

  def folio
    "LIQ-%04d" % (id.hash.abs % 10000)
  end
end
