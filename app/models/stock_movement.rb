class StockMovement < ApplicationRecord
  acts_as_tenant :account

  belongs_to :warehouse_item
  belongs_to :user
  belongs_to :asset, optional: true
  belongs_to :logbook_record, optional: true

  # 0: Ingreso / Compra, 1: Salida / Consumo OT, 2: Reservado para Auto, 3: Liberación de Reserva, 4: Ajuste Manual
  enum :movement_type, {
    entry: 0,
    exit: 1,
    reserve: 2,
    release: 3,
    adjustment: 4
  }, default: :entry

  validates :quantity, numericality: { greater_than: 0 }

  after_create :update_warehouse_stock

  def type_label
    case movement_type
    when "entry" then "Ingreso / Compra"
    when "exit" then "Salida / Instalación"
    when "reserve" then "Reserva para Vehículo"
    when "release" then "Liberación de Reserva"
    when "adjustment" then "Ajuste de Inventario"
    end
  end

  def type_badge_class
    case movement_type
    when "entry" then "bg-success"
    when "exit" then "bg-danger"
    when "reserve" then "bg-warning text-dark"
    when "release" then "bg-info text-dark"
    when "adjustment" then "bg-secondary"
    end
  end

  private

  def update_warehouse_stock
    item = warehouse_item
    case movement_type
    when "entry"
      item.stock_quantity += quantity
    when "exit"
      # Si ya estaba reservado previamente para esta OT/auto, se resta de reservado y físico
      if item.reserved_quantity >= quantity
        item.reserved_quantity -= quantity
      end
      item.stock_quantity = [item.stock_quantity - quantity, 0].max
    when "reserve"
      item.reserved_quantity += quantity
    when "release"
      item.reserved_quantity = [item.reserved_quantity - quantity, 0].max
    when "adjustment"
      item.stock_quantity = quantity
    end
    item.save!
  end
end
