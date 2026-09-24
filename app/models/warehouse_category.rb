class WarehouseCategory < ApplicationRecord
  acts_as_tenant :account

  validates :name, presence: true, uniqueness: { scope: :account_id }

  DEFAULT_CATEGORIES = [
    { name: "Lubricantes", description: "Aceites de motor, transmisión, fluidos hidráulicos y refrigerantes" },
    { name: "Filtros", description: "Filtros de aceite, aire, combustible y habitáculo" },
    { name: "Frenos", description: "Pastillas, discos, balatas, tambores y líquido de frenos" },
    { name: "Suspensión y Dirección", description: "Amortiguadores, terminales, rótulas y fuelles" },
    { name: "Eléctrico e Iluminación", description: "Baterías, ampolletas, alternadores y sensores" },
    { name: "Neumáticos y Ruedas", description: "Neumáticos, llantas, válvulas y parches" },
    { name: "Motor y Transmisión", description: "Correas, bujías, empaquetaduras y kits de embrague" },
    { name: "General", description: "Insumos varios, pernos, abrazaderas y químicos de limpieza" }
  ].freeze

  def self.seed_defaults_for_account!(account)
    return unless account
    DEFAULT_CATEGORIES.each do |cat|
      find_or_create_by!(account: account, name: cat[:name]) do |c|
        c.description = cat[:description]
      end
    end
  end
end
