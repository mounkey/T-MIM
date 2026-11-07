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
  has_many :warehouse_items, dependent: :destroy
  has_many :warehouse_categories, dependent: :destroy
  has_many :measurement_units, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :wiki_articles, dependent: :destroy

  belongs_to :region, optional: true
  belongs_to :city, optional: true

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
  validates :max_assets_limit, numericality: { greater_than_or_equal_to: 1 }

  PLANS = {
    "inicial" => {
      name: "Plan Inicial / Express",
      price_uf: 0.5,
      limit: 50,
      annual_limit: 60, # +20%
      description: "Ideal para talleres de motos, mecánica rápida y talleres que están iniciando.",
      modules: {
        vehicles: true,
        clients: true,
        logbook: :basic,
        warehouse: false,
        maintenance: false,
        finances: false,
        flow_payments: false
      },
      payment_modes: ["flow"] # Solo Flow / Tarjeta automática
    },
    "estandar" => {
      name: "Plan Estándar",
      price_uf: 1.5,
      limit: 50,
      annual_limit: 60,
      description: "Para talleres que buscan ordenar existencias de repuestos y bitácoras de servicio.",
      modules: {
        vehicles: true,
        clients: true,
        logbook: :full,
        warehouse: true,
        maintenance: true,
        finances: false,
        flow_payments: false
      },
      payment_modes: ["flow"] # Solo Flow / Tarjeta automática
    },
    "pro" => {
      name: "Plan Pro",
      price_uf: 2.5,
      limit: 150,
      annual_limit: 180,
      description: "Torre de control total: Órdenes de Trabajo (OT), desglose financiero y cotizaciones PDF.",
      modules: {
        vehicles: true,
        clients: true,
        logbook: :full,
        warehouse: true,
        maintenance: true,
        finances: true,
        flow_payments: false
      },
      payment_modes: ["flow"] # Solo Flow / Tarjeta automática
    },
    "full" => {
      name: "Plan Full",
      price_uf: 3.5,
      limit: 300,
      annual_limit: 360,
      description: "Automatización total: Pasarela Flow integrada, cobro en cuotas y liquidaciones.",
      modules: {
        vehicles: true,
        clients: true,
        logbook: :full,
        warehouse: true,
        maintenance: true,
        finances: true,
        flow_payments: true
      },
      payment_modes: ["flow", "transfer"] # Flow o Transferencia
    },
    "gran_taller" => {
      name: "Plan Gran Taller",
      price_uf: nil,
      limit: 9999,
      annual_limit: 9999,
      description: "Flujo masivo para concesionarios o talleres multimarca de alta rotación.",
      modules: {
        vehicles: true,
        clients: true,
        logbook: :full,
        warehouse: true,
        maintenance: true,
        finances: true,
        flow_payments: true
      },
      payment_modes: ["flow", "transfer"] # Flow o Transferencia
    }
  }.freeze

  # Helpers de Capacidad de Vehículos
  def effective_assets_limit
    base = max_assets_limit.presence || PLANS.dig(plan_type, :limit) || 50
    base + (extra_assets_quota || 0)
  end

  def can_add_asset?
    assets.count < effective_assets_limit
  end

  def capacity_percentage
    return 0 if effective_assets_limit.zero?
    ((assets.count.to_f / effective_assets_limit) * 100).round
  end

  def capacity_alert_level
    pct = capacity_percentage
    if pct >= 100
      :critical # Bloqueo rojo
    elsif pct >= 95
      :warning  # Alerta 95%
    elsif pct >= 75
      :notice
    else
      :normal
    end
  end

  # Comprueba si corresponde enviar la alerta de capacidad por email
  def check_and_send_capacity_warning!
    return unless capacity_alert_level == :warning || capacity_alert_level == :critical
    
    # Enviar solo una vez por mes o cada 7 días para no spamear
    if last_capacity_warning_sent_at.nil? || last_capacity_warning_sent_at < 7.days.ago
      target_email = email.presence || contacto_email
      if target_email.present?
        CapacityMailer.capacity_warning_email(self, target_email).deliver_later
        update_column(:last_capacity_warning_sent_at, Time.current)
      end
    end
  end

  # Helpers de Permisos de Módulos según Plan
  def plan_info
    PLANS[plan_type] || PLANS["inicial"]
  end

  def plan_name
    plan_info[:name]
  end

  def can_access_warehouse?
    plan_info.dig(:modules, :warehouse) == true
  end

  def can_access_maintenance?
    plan_info.dig(:modules, :maintenance) == true
  end

  def can_access_finances?
    plan_info.dig(:modules, :finances) == true
  end

  def can_access_flow_payments?
    plan_info.dig(:modules, :flow_payments) == true
  end

  def allows_transfer_billing?
    plan_info[:payment_modes].include?("transfer")
  end

  def manual_billing?
    billing_mode.to_s == "transfer" || billing_mode.to_s == "manual"
  end

  def flow_billing?
    !manual_billing?
  end

  # Contract & Activation helpers (Clon MIM)
  def contract_accepted?
    (contract_status == "active" || contract_status == "accepted") && contract_accepted_at.present?
  end

  def invitation_expired?
    invitation_expires_at.present? && Time.current > invitation_expires_at
  end

  def generate_invitation_token!
    self.invitation_token = SecureRandom.urlsafe_base64(32)
    self.invitation_sent_at = Time.current
    self.invitation_expires_at = 48.hours.from_now
    self.contract_status = "pending_activation"
    self.temporary_password ||= "Tmim-" + SecureRandom.hex(4)
    save(validate: false)
  end

  def accept_contract!(ip_address:, representative_rut:)
    update!(
      contract_status: "accepted",
      contract_accepted_at: Time.current,
      contract_accepted_ip: ip_address,
      contract_accepted_by_rut: representative_rut,
      contract_version: "v1.0-2026"
    )
  end

  def complete_onboarding_and_set_password!(new_password)
    ActiveRecord::Base.transaction do
      # 1. Crear o actualizar usuario administrador principal del taller
      admin_user = users.find_or_initialize_by(email: email.presence || contacto_email)
      admin_user.name = contacto_nombre.presence || name
      admin_user.password = new_password
      admin_user.password_confirmation = new_password
      admin_user.role = "admin" if admin_user.respond_to?(:role=)
      admin_user.save!

      # 2. Activar la cuenta
      update!(
        active: true,
        contract_status: "active",
        temporary_password: nil
      )
    end
  end
end
