class WarehouseItem < ApplicationRecord
  acts_as_tenant :account

  has_many :stock_movements, dependent: :destroy

  validates :name, presence: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }

  # Stock Disponible = Stock Físico - Stock Reservado
  def available_stock
    [stock_quantity - reserved_quantity, 0].max
  end

  def low_stock?
    stock_quantity <= minimum_stock
  end

  def out_of_stock?
    stock_quantity.zero?
  end

  def stock_status_badge
    if out_of_stock?
      { class: "bg-danger", label: "Agotado" }
    elsif low_stock?
      { class: "bg-warning text-dark", label: "Stock Bajo" }
    else
      { class: "bg-success", label: "Óptimo" }
    end
  end

  def display_name
    sku.present? ? "#{name} [#{sku}] (Disp: #{available_stock} #{unit})" : "#{name} (Disp: #{available_stock} #{unit})"
  end
end
