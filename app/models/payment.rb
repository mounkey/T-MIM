class Payment < ApplicationRecord
  acts_as_tenant :account

  belongs_to :payment_order
  belongs_to :user, optional: true

  enum :payment_channel, {
    cash: 0,
    pos_local: 1,
    transfer_local: 2,
    flow_online: 3
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true

  before_validation :set_default_recorded_at, on: :create
  before_save :calculate_fees_and_net

  def payment_channel_label
    case payment_channel.to_sym
    when :cash
      "Efectivo (Caja)"
    when :pos_local
      "Tarjeta POS (Taller)"
    when :transfer_local
      "Transferencia (Taller)"
    when :flow_online
      "Flow (Online)"
    end
  end

  def payment_channel_badge
    case payment_channel.to_sym
    when :flow_online
      { label: "Flow (Online)", class: "bg-info text-dark" }
    else
      { label: "Presencial", class: "bg-secondary text-white" }
    end
  end

  private

  def set_default_recorded_at
    self.recorded_at ||= Time.current
  end

  def calculate_fees_and_net
    if flow_online?
      # 1. Costo Pasarela Flow: 2.89% ($2.890 por cada $100.000)
      self.flow_fee = (amount * 0.0289).round(2)

      # 2. Comisión T-MIM Plataforma: 5.0% ($5.000 por cada $100.000)
      percent_setting = SystemSetting.find_by(key: 'ONLINE_COMMISSION_PERCENT')&.value
      tmim_rate = (percent_setting.present? ? percent_setting.to_f : 5.0) / 100.0
      self.platform_fee = (amount * tmim_rate).round(2)

      # 3. Monto Neto Líquido a Transferir al Taller
      self.net_amount = [amount - flow_fee - platform_fee, 0].max
    else
      # Presencial: 0% comisión
      self.flow_fee = 0.0
      self.platform_fee = 0.0
      self.net_amount = amount
    end
  end
end
