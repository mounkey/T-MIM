# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Admin User
account = Account.find_or_create_by!(name: 'Default Account', subdomain: 'default', active: true)
admin = User.find_or_initialize_by(email: 'admin@mim.cl', account: account)
admin.update!(
  name: 'Juan Pablo Grover Pinto',
  run: '134148897-7',
  password: '123456',
  password_confirmation: '123456',
  role: :admin
)
puts "Admin user created: #{admin.email} / 123456"

# Regions and Cities (Chile) - Updated with Roman Numerals based on User Request
regions_data = [
  { name: "Arica y Parinacota", code: "XV", cities: ["Arica", "Putre"] },
  { name: "Tarapacá", code: "I", cities: ["Iquique", "Alto Hospicio"] },
  { name: "Antofagasta", code: "II", cities: ["Antofagasta", "Calama", "Tocopilla"] },
  { name: "Atacama", code: "III", cities: ["Copiapó", "Vallenar"] },
  { name: "Coquimbo", code: "IV", cities: ["La Serena", "Coquimbo", "Ovalle"] },
  { name: "Valparaíso", code: "V", cities: ["Valparaíso", "Viña del Mar", "San Antonio"] },
  { name: "Metropolitana de Santiago", code: "RM", cities: ["Santiago", "Puente Alto", "Maipú", "Las Condes"] },
  { name: "Libertador General Bernardo O'Higgins", code: "VI", cities: ["Rancagua", "San Fernando"] },
  { name: "Maule", code: "VII", cities: ["Talca", "Curicó", "Linares"] },
  { name: "Ñuble", code: "XVI", cities: ["Chillán", "San Carlos"] },
  { name: "Biobío", code: "VIII", cities: ["Concepción", "Los Ángeles", "Talcahuano"] },
  { name: "La Araucanía", code: "IX", cities: ["Temuco", "Villarrica"] },
  { name: "Los Ríos", code: "XIV", cities: ["Valdivia", "La Unión"] },
  { name: "Los Lagos", code: "X", cities: ["Puerto Montt", "Osorno", "Castro"] },
  { name: "Aysén del General Carlos Ibáñez del Campo", code: "XI", cities: ["Coyhaique", "Aysén"] },
  { name: "Magallanes y de la Antártica Chilena", code: "XII", cities: ["Punta Arenas", "Puerto Natales"] }
]

regions_data.each do |data|
  # Using find_or_initialize_by and then update! allows us to update the code if the name exists
  region = Region.find_or_initialize_by(name: data[:name])
  region.update!(code: data[:code])

  data[:cities].each do |city_name|
    City.find_or_create_by(name: city_name, region: region)
  end
end

puts "Regions and Cities seeded."

# Asset Categories
categories = [
  { name: "Maquinaria Pesada", description: "Excavadoras, grúas, cargadores frontales." },
  { name: "Vehículos Menores", description: "Camionetas, autos de servicio." },
  { name: "Herramientas Eléctricas", description: "Generadores, taladros industriales." },
  { name: "Equipos de Computación", description: "Laptops, servidores, tablets robustas." }
]

categories.each do |cat|
  AssetCategory.find_or_create_by(name: cat[:name]) do |c|
    c.description = cat[:description]
  end
end

puts "Asset Categories seeded."

# Tags (Skills)
tags = [
  { name: "Hidráulica", description: "Especialista en sistemas hidráulicos." },
  { name: "Mecánica Diesel", description: "Motores diesel y transmisión." },
  { name: "Electrónica", description: "Sistemas electrónicos y sensores." },
  { name: "Soldadura", description: "Estructuras metálicas y soldadura de precisión." }
]

tags.each do |tag|
  Tag.find_or_create_by(name: tag[:name]) do |t|
    t.description = tag[:description]
  end
end

puts "Tags seeded."
