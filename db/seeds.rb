# db/seeds.rb
require "date"
puts "🧹 Limpiando base de datos..."

# Orden correcto para no violar FKs
Review.destroy_all
Order.destroy_all
Availability.destroy_all
Blackout.destroy_all
Service.destroy_all
Message.destroy_all   # <- NUEVO
Chat.destroy_all      # <- NUEVO
PgSearch::Document.destroy_all if defined?(PgSearch::Document)
ActiveStorage::Attachment.destroy_all
ActiveStorage::Blob.destroy_all

User.destroy_all

puts "👥 Creando usuarios..."

# ==== SUPPLIERS ====
puts "Creando suppliers..."

# 5 suppliers originales (respetamos tu estructura)
supplier1 = User.create!(
  first_name: "Carlos",
  last_name: "Mendoza",
  email: "carlos.mendoza@mail.com",
  password: "123456",
  phone: "11-4567-8901",
  address: "Av. Santa Fe 3300, Buenos Aires",  # Palermo
  role: "supplier",
  radius: 5,
  latitude: -34.5945,
  longitude: -58.3974
)

supplier2 = User.create!(
  first_name: "Andrea",
  last_name: "Gómez",
  email: "andrea.gomez@mail.com",
  password: "123456",
  phone: "11-5678-9012",
  address: "Av. Córdoba 5500, Buenos Aires",  # Palermo Hollywood
  role: "supplier",
  radius: 2,
  latitude: -34.5889,
  longitude: -58.4242
)

supplier3 = User.create!(
  first_name: "José",
  last_name: "Rodríguez",
  email: "jose.rodriguez@mail.com",
  password: "123456",
  phone: "11-6789-0123",
  address: "Av. Cabildo 2000, Buenos Aires",  # Belgrano
  role: "supplier",
  radius: 6,
  latitude: -34.5614,
  longitude: -58.4569
)

supplier4 = User.create!(
  first_name: "María",
  last_name: "Fernández",
  email: "maria.fernandez@mail.com",
  password: "123456",
  phone: "11-7890-1234",
  address: "Av. Rivadavia 8000, Buenos Aires",  # Flores
  role: "supplier",
  radius: 10,
  latitude: -34.6286,
  longitude: -58.4689
)

supplier5 = User.create!(
  first_name: "Luis",
  last_name: "Sánchez",
  email: "luis.sanchez@mail.com",
  password: "123456",
  phone: "11-8901-2345",
  address: "Av. Libertador 7500, Buenos Aires",  # Núñez
  role: "supplier",
  radius: 15,
  latitude: -34.5442,
  longitude: -58.4644
)

suppliers = [supplier1, supplier2, supplier3, supplier4, supplier5]
puts "✅ Suppliers creados con direcciones y radius configurados"

# ==== CLIENTS ====
puts "Creando clientes..."

client_reference = User.create!(
  first_name: "Valentina",
  last_name: "Pérez",
  email: "valentina.perez@mail.com",
  password: "123456",
  phone: "11-2345-6789",
  address: "Jorge Luis Borges 1700, Buenos Aires",
  role: "client",
  latitude: -34.5895,
  longitude: -58.4322
)

clients = [client_reference]

clients << User.create!(
  first_name: "Tomás",
  last_name: "González",
  email: "tomas.gonzalez@mail.com",
  password: "123456",
  phone: "11-3456-7890",
  address: "Av. Corrientes 1500, Buenos Aires",
  role: "client",
  latitude: -34.6037,
  longitude: -58.3816
)

clients << User.create!(
  first_name: "Camila",
  last_name: "López",
  email: "camila.lopez@mail.com",
  password: "123456",
  phone: "11-4567-8902",
  address: "Florida 800, Buenos Aires",
  role: "client",
  latitude: -34.5986,
  longitude: -58.3745
)

clients << User.create!(
  first_name: "Sebastián",
  last_name: "Martínez",
  email: "sebastian.martinez@mail.com",
  password: "123456",
  phone: "11-5678-9013",
  address: "Av. Las Heras 2100, Buenos Aires",
  role: "client",
  latitude: -34.5878,
  longitude: -58.3956
)

clients << User.create!(
  first_name: "Fernanda",
  last_name: "Díaz",
  email: "fernanda.diaz@mail.com",
  password: "123456",
  phone: "11-6789-0124",
  address: "Defensa 900, Buenos Aires",
  role: "client",
  latitude: -34.6214,
  longitude: -58.3731
)

clients << User.create!(
  first_name: "Ignacio",
  last_name: "Silva",
  email: "ignacio.silva@mail.com",
  password: "123456",
  phone: "11-7890-1235",
  address: "Av. del Libertador 2500, Buenos Aires",
  role: "client",
  latitude: -34.5767,
  longitude: -58.4034
)

clients << User.create!(
  first_name: "Rocío",
  last_name: "Castro",
  email: "rocio.castro@mail.com",
  password: "123456",
  phone: "11-8901-2346",
  address: "Av. Scalabrini Ortiz 1800, Buenos Aires",
  role: "client",
  latitude: -34.5892,
  longitude: -58.4245
)

clients << User.create!(
  first_name: "Martín",
  last_name: "Rojas",
  email: "martin.rojas@mail.com",
  password: "123456",
  phone: "11-9012-3457",
  address: "Av. Pueyrredón 1200, Buenos Aires",
  role: "client",
  latitude: -34.5934,
  longitude: -58.4012
)

clients << User.create!(
  first_name: "Sofía",
  last_name: "Herrera",
  email: "sofia.herrera@mail.com",
  password: "123456",
  phone: "11-0123-4568",
  address: "Av. Callao 800, Buenos Aires",
  role: "client",
  latitude: -34.5989,
  longitude: -58.3923
)

clients << User.create!(
  first_name: "Joaquín",
  last_name: "Vega",
  email: "joaquin.vega@mail.com",
  password: "123456",
  phone: "11-1234-5679",
  address: "Av. Juan B. Justo 5000, Buenos Aires",
  role: "client",
  latitude: -34.5992,
  longitude: -58.4378
)

puts "✅ #{clients.count} clientes creados"

puts "🧰 Creando servicios para cada supplier..."

supplier1.services.create!([
  {
    category: "Hogar",
    sub_category: "Plomeria",
    description: "Servicio profesional de plomería para el hogar. Reparaciones, instalaciones y mantenimiento. Más de 10 años de experiencia en la zona de Palermo y alrededores.",
    price: 3500,
    published: true,
    duration_minutes: 90
  },
  {
    category: "Hogar",
    sub_category: "Electricidad",
    description: "Instalaciones eléctricas, reparaciones y mantenimiento. Trabajo garantizado y con materiales de primera calidad. Atención rápida en emergencias.",
    price: 4000,
    published: true,
    duration_minutes: 60
  }
])

supplier2.services.create!([
  {
    category: "Estética",
    sub_category: "Peluquería",
    description: "Cortes de pelo modernos, coloración y tratamientos capilares. Especializada en tendencias actuales. Atención personalizada en Palermo Hollywood.",
    price: 2500,
    published: true,
    duration_minutes: 60
  },
  {
    category: "Estética",
    sub_category: "Maquillaje",
    description: "Maquillaje profesional para eventos, bodas y sesiones fotográficas. Productos de alta gama. Experiencia en todo tipo de pieles.",
    price: 3000,
    published: true,
    duration_minutes: 60
  }
])

supplier3.services.create!([
  {
    category: "Cuidados",
    sub_category: "Cuidado de niños",
    description: "Niñera con amplia experiencia en el cuidado de niños de todas las edades. Referencias verificables. Disponibilidad para jornadas completas o por horas.",
    price: 1500,
    published: true,
    duration_minutes: 180
  },
  {
    category: "Hogar",
    sub_category: "Limpieza",
    description: "Servicio de limpieza profunda para hogares y oficinas. Productos ecológicos disponibles. Equipo profesional y confiable.",
    price: 2800,
    published: true,
    duration_minutes: 120
  }
])

supplier4.services.create!([
  {
    category: "Wellness",
    sub_category: "Masajes",
    description: "Masajes terapéuticos, descontracturantes y relajantes. Certificada en diferentes técnicas. Atención a domicilio en zona oeste de Buenos Aires.",
    price: 4500,
    published: true,
    duration_minutes: 60
  },
  {
    category: "Wellness",
    sub_category: "Clases de Yoga",
    description: "Clases particulares de yoga en tu domicilio. Todos los niveles. Incluye mat y elementos necesarios. Horarios flexibles.",
    price: 3200,
    published: true,
    duration_minutes: 60
  }
])

supplier5.services.create!([
  {
    category: "Entrenamiento",
    sub_category: "Personal Trainer",
    description: "Entrenamiento personalizado a domicilio. Planes adaptados a tus objetivos. Experiencia con clientes de todos los niveles. Zona norte y centro de Buenos Aires.",
    price: 5000,
    published: true,
    duration_minutes: 60
  },
  {
    category: "Entrenamiento",
    sub_category: "Funcional",
    description: "Entrenamiento funcional grupal o individual. Rutinas dinámicas y efectivas. Incluye seguimiento nutricional básico.",
    price: 3800,
    published: true,
    duration_minutes: 90
  },
  {
    category: "Clases",
    sub_category: "Idiomas",
    description: "Clases particulares de inglés para todos los niveles. Preparación para exámenes internacionales. Metodología conversacional y práctica.",
    price: 2000,
    published: true,
    duration_minutes: 60
  }
])

services = Service.all
puts "✅ #{services.count} servicios creados"

# ======== A PARTIR DE ACÁ: ENRIQUECIMIENTO MASIVO SEGÚN TUS REGLAS ========

# Ayudantes
def rand_price_for(subcat)
  base = {
    "Plomeria" => 15000..35000,
    "Electricidad" => 15000..35000,
    "Jardinería" => 10000..28000,
    "Limpieza" => 8000..20000,
    "Planchado" => 6000..12000,
    "Control de Plagas" => 18000..40000,
    "Cuidado de niños" => 6000..12000,
    "Cuidado de ancianos" => 8000..18000,
    "Peluquería" => 9000..25000,
    "Maquillaje" => 12000..30000,
    "Depilación" => 7000..16000,
    "Estética Facial" => 10000..26000,
    "Manos y Pies" => 7000..15000,
    "Clases de Yoga" => 8000..18000,
    "Masajes" => 12000..28000,
    "Clases de Pilates" => 9000..20000,
    "Clases de Meditacion" => 7000..14000,
    "Personal Trainer" => 12000..26000,
    "Funcional" => 10000..22000,
    "Idiomas" => 8000..20000
  }
  range = base[subcat] || (9000..22000)
  rand(range)
end

BA_SUBCATS = {
  "Hogar" => ["Control de Plagas", "Electricidad", "Jardinería", "Limpieza", "Planchado", "Plomeria"],
  "Cuidados" => ["Cuidado de niños", "Cuidado de ancianos"],
  "Estética" => ["Peluquería", "Maquillaje", "Depilación", "Estética Facial", "Manos y Pies"],
  "Wellness" => ["Clases de Yoga", "Masajes", "Clases de Pilates", "Clases de Meditacion"],
  "Entrenamiento" => ["Personal Trainer", "Funcional"],
  "Clases" => ["Idiomas"]
}

ALL_SUBCATS = BA_SUBCATS.values.flatten.freeze

# Direcciones reales (calle + altura) y coordenadas aproximadas

BA_ADDRESSES = [
  ["Honduras 5200, Palermo, CABA", -34.5887, -58.4286],
  ["Gorriti 4800, Palermo, CABA", -34.5912, -58.4307],
  ["Thames 1600, Palermo, CABA", -34.5927, -58.4300],
  ["Costa Rica 5600, Palermo, CABA", -34.5826, -58.4366],
  ["Armenia 1800, Palermo, CABA", -34.5899, -58.4290],
  ["Malabia 1700, Palermo, CABA", -34.5930, -58.4302],
  ["Nicaragua 5500, Palermo, CABA", -34.5840, -58.4354],
  ["Av. Cabildo 2400, Belgrano, CABA", -34.5599, -58.4560],
  ["Juramento 1800, Belgrano, CABA", -34.5628, -58.4567],
  ["Conesa 1800, Belgrano, CABA", -34.5677, -58.4569],
  ["Mendoza 1900, Belgrano, CABA", -34.5634, -58.4561],
  ["3 de Febrero 2400, Belgrano, CABA", -34.5722, -58.4448],
  ["Vuelta de Obligado 2000, Belgrano, CABA", -34.5649, -58.4568],
  ["Olazábal 2200, Belgrano, CABA", -34.5614, -58.4624],
  ["Amenábar 1800, Belgrano, CABA", -34.5683, -58.4560],
  ["Av. Rivadavia 6200, Caballito, CABA", -34.6188, -58.4404],
  ["Av. La Plata 100, Caballito, CABA", -34.6197, -58.4290],
  ["Av. Pedro Goyena 700, Caballito, CABA", -34.6252, -58.4341],
  ["Av. Scalabrini Ortiz 1200, CABA", -34.5884, -58.4218],
  ["Av. Córdoba 3500, CABA", -34.5978, -58.4088],
  ["Av. Corrientes 3500, CABA", -34.6041, -58.4105],
  ["Av. Pueyrredón 900, CABA", -34.5949, -58.4021],
  ["Av. Callao 1200, CABA", -34.6005, -58.3950],
  ["Av. Santa Fe 2450, CABA", -34.5938, -58.4029],
  ["Gurruchaga 1800, Palermo, CABA", -34.5920, -58.4274],
  ["Niceto Vega 5600, Palermo, CABA", -34.5849, -58.4390],
  ["Arévalo 1500, Palermo, CABA", -34.5796, -58.4369],
  ["Dorrego 1700, Palermo, CABA", -34.5785, -58.4360],
  ["Federico Lacroze 2100, Colegiales, CABA", -34.5808, -58.4510],
  ["Zapiola 1000, Colegiales, CABA", -34.5790, -58.4580]
].freeze

MZA_ADDRESSES = [
  ["Av. Arístides Villanueva 300, Mendoza", -32.8897, -68.8461],
  ["Chile 900, Ciudad de Mendoza", -32.8890, -68.8423],
  ["Mitre 1100, Ciudad de Mendoza", -32.8904, -68.8469],
  ["Av. Colón 400, Ciudad de Mendoza", -32.8880, -68.8451],
  ["Sarmiento 400, Ciudad de Mendoza", -32.8893, -68.8447],
  ["San Lorenzo 500, Ciudad de Mendoza", -32.8899, -68.8484],
  ["Belgrano 900, Ciudad de Mendoza", -32.8923, -68.8458],
  ["Av. Emilio Civit 300, Ciudad de Mendoza", -32.8920, -68.8536],
  ["Olascoaga 500, Ciudad de Mendoza", -32.8932, -68.8524],
  ["Godoy Cruz 500, Ciudad de Mendoza", -32.8926, -68.8455],
  ["Italia 200, Godoy Cruz", -32.9246, -68.8443],
  ["San Martín 1500, Godoy Cruz", -32.9312, -68.8445],
  ["Rivadavia 500, Godoy Cruz", -32.9241, -68.8409],
  ["Balcarce 300, Godoy Cruz", -32.9317, -68.8422],
  ["Tomba 200, Godoy Cruz", -32.9275, -68.8428],
  ["Viamonte 5000, Chacras de Coria", -33.0072, -68.8567],
  ["Italia 5700, Chacras de Coria", -33.0076, -68.8473],
  ["Darragueira 700, Chacras de Coria", -33.0069, -68.8492],
  ["Loria 500, Chacras de Coria", -33.0091, -68.8510],
  ["Besares 1400, Chacras de Coria", -33.0062, -68.8519],
  ["San Martín 300, Luján de Cuyo", -33.0451, -68.8752],
  ["Sáenz Peña 200, Luján de Cuyo", -33.0413, -68.8744],
  ["Patricios 100, Luján de Cuyo", -33.0400, -68.8732],
  ["Viamonte 100, Luján de Cuyo", -33.0422, -68.8770],
  ["San Martín 1000, Maipú", -32.9874, -68.7923],
  ["Pablo Pescara 200, Maipú", -32.9861, -68.7921],
  ["25 de Mayo 400, Maipú", -32.9869, -68.7912],
  ["Sarmiento 800, Maipú", -32.9878, -68.7900],
  ["Belgrano 600, Maipú", -32.9883, -68.7909],
  ["Ozamis 300, Maipú", -32.9859, -68.7970]
].freeze

# Generar 30 suppliers BA (ya tenemos 5 de BA)
def gen_person(i)
  first = %w[Agustín Felipe Facundo Nicolás Julieta Lucía Paula Antonella Florencia Carla
             Pedro Ramiro Gonzalo Ignacio Juan Pablo Diego Micaela Sol Valentina Candela
             Martina Emilia Camilo Bruno Joaquín Mateo Tomás Zoe Lara Jazmín Bianca Milagros].sample
  last = %w[Pérez Gómez Rodríguez Fernández López Díaz Martínez García Romero Torres
            Castro Herrera Silva Rojas Vega Morales Sánchez Navarro Moyano Ponce].sample
  [first, last]
end

# Para emails únicos
used_emails = User.pluck(:email).to_set

def unique_email(base, used)
  email = base
  n = 1
  while used.include?(email)
    email = base.sub("@", "+#{n}@")
    n += 1
  end
  used << email
  email
end

# completar suppliers BA hasta 30
(6..30).each do |idx|
  name = gen_person(idx)
  addr, lat, lon = BA_ADDRESSES[(idx - 6) % BA_ADDRESSES.size]
  email = unique_email("#{name[0].downcase}.#{name[1].downcase}@ba-suppliers.com", used_emails)
  suppliers << User.create!(
    first_name: name[0],
    last_name:  name[1],
    email: email,
    password: "123456",
    phone: "11-#{rand(1000..9999)}-#{rand(1000..9999)}",
    address: addr,
    role: "supplier",
    radius: [2,3,5,8,10,12,15].sample,
    latitude: lat,
    longitude: lon
  )
end

# 30 suppliers MZA
(1..30).each do |idx|
  name = gen_person(idx + 100)
  addr, lat, lon = MZA_ADDRESSES[(idx - 1) % MZA_ADDRESSES.size]
  email = unique_email("#{name[0].downcase}.#{name[1].downcase}@mza-suppliers.com", used_emails)
  suppliers << User.create!(
    first_name: name[0],
    last_name:  name[1],
    email: email,
    password: "123456",
    phone: "261-#{rand(4000000..7999999)}",
    address: addr,
    role: "supplier",
    radius: [2,3,5,8,10,12,15].sample,
    latitude: lat,
    longitude: lon
  )
end

puts "✅ Total suppliers: #{User.where(role: 'supplier').count} (30 BA + 30 MZA)"

# Servicios: aseguramos cobertura de TODAS las subcategorías en cada ciudad,
# y que cada supplier tenga al menos 1 servicio
def city_for_address(addr)
  if addr.include?("Mendoza") || addr.include?("Godoy Cruz") || addr.include?("Chacras") || addr.include?("Luján") || addr.include?("Maipú")
    :mza
  else
    :ba
  end
end

def category_for_sub(sub)
  BA_SUBCATS.find { |k, v| v.include?(sub) }&.first || "Hogar"
end

# Mapear subcategorías para asignarlas cíclicamente por ciudad
ba_cycle = ALL_SUBCATS.cycle
mza_cycle = ALL_SUBCATS.cycle

User.where(role: "supplier").find_each do |sup|
  sub = (city_for_address(sup.address) == :ba ? ba_cycle.next : mza_cycle.next)
  cat = category_for_sub(sub)
  sup.services.create!(
    category: cat,
    sub_category: sub,
    description: "#{sub} profesional en la zona. Atención a domicilio, materiales de calidad y cumplimiento horario.",
    price: rand_price_for(sub),
    published: true,
    duration_minutes: [45,60,75,90,120].sample
  )
  # Bonus: hasta 1 extra aleatorio (30-40% de los casos)
  if [true, false, false].sample
    sub2 = (city_for_address(sup.address) == :ba ? ba_cycle.next : mza_cycle.next)
    cat2 = category_for_sub(sub2)
    sup.services.create!(
      category: cat2,
      sub_category: sub2,
      description: "#{sub2} con experiencia comprobable. Servicio garantizado.",
      price: rand_price_for(sub2),
      published: [true, true, false].sample,
      duration_minutes: [45,60,90].sample
    )
  end
end

puts "✅ Servicios asignados y cobertura de subcategorías en ambas ciudades"

# ==== Completar CLIENTES hasta 60 (30 BA y 30 MZA) ====
# Ya hay 10 BA. Creamos 20 BA + 30 MZA.

# 20 BA extras
(1..20).each do |i|
  name = gen_person(200 + i)
  addr, lat, lon = BA_ADDRESSES[i % BA_ADDRESSES.size]
  email = unique_email("#{name[0].downcase}.#{name[1].downcase}@ba-clients.com", used_emails)
  clients << User.create!(
    first_name: name[0],
    last_name:  name[1],
    email: email,
    password: "123456",
    phone: "11-#{rand(2000..9999)}-#{rand(1000..9999)}",
    address: addr,
    role: "client",
    latitude: lat,
    longitude: lon
  )
end

# 30 MZA clients
(1..30).each do |i|
  name = gen_person(300 + i)
  addr, lat, lon = MZA_ADDRESSES[i % MZA_ADDRESSES.size]
  email = unique_email("#{name[0].downcase}.#{name[1].downcase}@mza-clients.com", used_emails)
  clients << User.create!(
    first_name: name[0],
    last_name:  name[1],
    email: email,
    password: "123456",
    phone: "261-#{rand(4000000..7999999)}",
    address: addr,
    role: "client",
    latitude: lat,
    longitude: lon
  )
end

puts "✅ #{clients.count} clientes totales (30 BA + 30 MZA)"

# ==== Agenda: disponibilidades y bloqueos ====

# Disponibilidad semanal (Lun–Vie 09–13 y 14–18) para TODOS los suppliers
(1..5).each do |wday| # 1=Lun ... 5=Vie
  User.where(role: "supplier").find_each do |sup|
    sup.availabilities.create!(wday: wday, start_time: "09:00", end_time: "13:00")
    sup.availabilities.create!(wday: wday, start_time: "14:00", end_time: "18:00")
  end
end
puts "✅ Disponibilidades semanales creadas para todos los suppliers"

# Próximo día hábil (para probar bloqueo a nivel proveedor sobre supplier1)
def next_weekday(from_date = Date.current)
  d = from_date
  d += 1.day while [0, 6].include?(d.wday) # saltear domingo(0) y sábado(6)
  d
end
test_date = next_weekday

# Blackout 12:00–13:00 para supplier1 ese día
supplier1.blackouts.create!(
  starts_at: Time.zone.local(test_date.year, test_date.month, test_date.day, 12, 0, 0),
  ends_at:   Time.zone.local(test_date.year, test_date.month, test_date.day, 13, 0, 0),
  reason: "Almuerzo (demo)"
)
puts "✅ Blackout 12:00–13:00 creado para supplier1 en #{test_date}"

# ==== Órdenes de ejemplo (respetando tu estructura) ====

puts "📅 Creando órdenes de ejemplo..."

# 1) Dos órdenes "confirmed" el mismo día (test_date) para supplier1
service_elec = supplier1.services.find_by(sub_category: "Electricidad") || supplier1.services.first
service_plom = supplier1.services.find_by(sub_category: "Plomeria") || supplier1.services.last

Order.create!(
  user: clients.sample,
  service: service_elec,
  service_address: "Dirección del cliente",
  total_price: service_elec.price,
  status: "confirmed",                            # <- estado que bloquea
  date: test_date,
  start_time: "10:00",
  end_time:   "11:00"
)

Order.create!(
  user: clients.sample,
  service: service_plom,
  service_address: "Dirección del cliente",
  total_price: service_plom.price,
  status: "confirmed",                            # <- bloquea a NIVEL PROVEEDOR
  date: test_date,
  start_time: "15:00",
  end_time:   "16:30"
)

# 2) Otras 12 órdenes aleatorias (ANULADAS para no romper el total de 200)
# 0.times do
#   client  = clients.sample
#   service = Service.all.sample
#   status_pool = %w[pending confirmed completed canceled]
#   status = status_pool.sample
#   day  = Date.current + rand(-15..15).days
#   st_h = rand(8..18)
#   st_m = [0, 30].sample
#   dur  = service.duration_minutes
#   en_time = (Time.zone.local(2000,1,1, st_h, st_m) + dur.minutes)
#   end_h = en_time.hour
#   end_m = en_time.min
#   Order.create!(
#     user: client,
#     service: service,
#     service_address: client.address,
#     total_price: service.price,
#     status: status,
#     date: day,
#     start_time: format("%02d:%02d", st_h, st_m),
#     end_time:   format("%02d:%02d", end_h, end_m)
#   )
# end

orders = Order.all
puts "✅ #{orders.count} órdenes creadas (parciales de demo)"

# ====== GENERADOR CONTROLADO PARA LLEGAR A 200 ÓRDENES EXACTAS ======
target_total = 200
already_confirmed = Order.where(status: "confirmed").count
already_completed = Order.where(status: "completed").count
already_canceled  = Order.where(status: "canceled").count
already_total     = Order.count

need_completed = 120 - already_completed
need_confirmed = 60  - already_confirmed
need_canceled  = 20  - already_canceled

# No permitir negativos si ya hubiera algo previo
need_completed = [need_completed, 0].max
need_confirmed = [need_confirmed, 0].max
need_canceled  = [need_canceled, 0].max

def random_slot_for(service)
  # ventana de 30 días pasado/futuro
  day = Date.current + rand(-15..15).days
  st_h = [9,10,11,14,15,16,17].sample
  st_m = [0, 30].sample
  dur  = service.duration_minutes
  en_time = (Time.zone.local(2000,1,1, st_h, st_m) + dur.minutes)
  end_h = en_time.hour
  end_m = en_time.min
  [day, format("%02d:%02d", st_h, st_m), format("%02d:%02d", end_h, end_m)]
end

def create_n_orders(n, status, clients)
  n.times do
    svc = Service.order("RANDOM()").first
    cl  = clients.sample
    day, st, en = random_slot_for(svc)
    Order.create!(
      user: cl,
      service: svc,
      service_address: cl.address,
      total_price: svc.price,
      status: status,
      date: day,
      start_time: st,
      end_time:   en
    )
  end
end

create_n_orders(need_completed, "completed", clients)
create_n_orders(need_confirmed, "confirmed", clients)
create_n_orders(need_canceled,  "canceled",  clients)

# Si por algún motivo faltaran órdenes para llegar a 200 exactas (p.e. si arriba hubo redondeos),
# rellenamos con 'completed' hasta completar el total.
missing = target_total - Order.count
create_n_orders([missing, 0].max, "completed", clients)

puts "✅ Totales finales de órdenes:"
puts "   completed: #{Order.where(status: 'completed').count}"
puts "   confirmed: #{Order.where(status: 'confirmed').count}"
puts "   canceled : #{Order.where(status: 'canceled').count}"
puts "   TOTAL    : #{Order.count}"

# ==== Reseñas (sólo órdenes COMPLETED, 2 por orden) ====
puts "⭐ Creando reseñas..."

completed_orders = Order.where(status: "completed")

client_texts = [
  "Excelente servicio, puntual y muy profesional.",
  "Muy buena experiencia, volvería a contratar.",
  "Trabajo prolijo y comunicación clara.",
  "Precio justo y resultado impecable.",
  "Todo perfecto, gracias por la atención."
]

supplier_texts = [
  "Cliente cordial y cumplidor con los horarios.",
  "Excelente comunicación, todo salió como acordado.",
  "Un gusto trabajar con el cliente.",
  "Muy responsable y respetuoso.",
  "Experiencia fluida y sin inconvenientes."
]

completed_orders.find_each do |order|
  # review del CLIENTE -> PROVEEDOR
  Review.create!(
    rating: rand(4.0..5.0).round(1),
    content: client_texts.sample,
    service: order.service,
    client: order.user,
    supplier: order.service.user
  )
  # review del PROVEEDOR -> CLIENTE
  Review.create!(
    rating: rand(4.0..5.0).round(1),
    content: supplier_texts.sample,
    service: order.service,
    client: order.user,
    supplier: order.service.user
  )
end

puts "✅ #{Review.count} reseñas creadas (2 por cada completed)"

puts "—"
puts "🧪 Día de prueba (supplier1): #{test_date} (#{%w[Dom Lun Mar Mié Jue Vie Sáb][test_date.wday]})"
puts "    Blackout    : 12:00–13:00"
puts "    Reserva 1   : Electricidad 10:00–11:00 (confirmed)"
puts "    Reserva 2   : Plomeria     15:00–16:30 (confirmed)"
puts "—"
puts "== Seed OK =="
