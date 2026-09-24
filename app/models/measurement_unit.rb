class MeasurementUnit < ApplicationRecord
  acts_as_tenant :account

  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :abbreviation, presence: true

  DEFAULT_UNITS = [
    { name: "Unidad", abbreviation: "un", description: "Pieza individual o repuesto único" },
    { name: "Litro", abbreviation: "L", description: "Medida de volumen para fluidos y aceites" },
    { name: "Bidón (5L)", abbreviation: "bidón", description: "Envase de 5 litros" },
    { name: "Tambor (200L)", abbreviation: "tambor", description: "Tambor industrial de 200 litros" },
    { name: "Juego / Kit", abbreviation: "kit", description: "Conjunto o kit completo (ej. pastillas x4, kit de embrague)" },
    { name: "Par", abbreviation: "par", description: "Pareja de elementos (ej. par de amortiguadores)" },
    { name: "Metro", abbreviation: "m", description: "Largo para mangueras, cables o correas" },
    { name: "Kilogramo", abbreviation: "kg", description: "Peso para grasas o pastas" },
    { name: "Hora", abbreviation: "hr", description: "Tiempo de servicio o mano de obra especializada" }
  ].freeze

  def self.seed_defaults_for_account!(account)
    return unless account
    DEFAULT_UNITS.each do |unit|
      find_or_create_by!(account: account, name: unit[:name]) do |u|
        u.abbreviation = unit[:abbreviation]
        u.description = unit[:description]
      end
    end
  end

  def display_name
    "#{name} (#{abbreviation})"
  end
end
