# db/seeds.rb
require "date"

puts "🧹 Limpiando base de datos..."
Review.destroy_all
Order.destroy_all
Availability.destroy_all
Blackout.destroy_all
Service.destroy_all
User.destroy_all

puts "👥 Creando usuarios..."

# ==== SUPPLIERS ====
puts "Creando suppliers..."

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

# ==== Agenda: disponibilidades y bloqueos ====

# Disponibilidad semanal (Lun–Vie 09–13 y 14–18) para todos los suppliers
(1..5).each do |wday| # 1=Lun ... 5=Vie
  suppliers.each do |sup|
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

# ==== Órdenes de ejemplo ====

puts "📅 Creando órdenes de ejemplo..."

# 1) Dos órdenes "confirmed" el mismo día (test_date) para supplier1
service_elec = supplier1.services.find_by(sub_category: "Electricidad")
service_plom = supplier1.services.find_by(sub_category: "Plomeria")

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

# 2) Otras 12 órdenes aleatorias (como tenías)
12.times do
  client  = clients.sample
  service = services.sample
  # estados variados (los que bloquean deben ser "confirmed")
  status_pool = %w[pending confirmed completed canceled]
  status = status_pool.sample

  # Fecha aleatoria en ±15 días
  day  = Date.current + rand(-15..15).days
  # Horarios razonables
  st_h = rand(8..18)
  st_m = [0, 30].sample
  dur  = service.duration_minutes
  en_time = (Time.zone.local(2000,1,1, st_h, st_m) + dur.minutes)
  end_h = en_time.hour
  end_m = en_time.min

  Order.create!(
    user: client,
    service: service,
    service_address: client.address,
    total_price: service.price,
    status: status,
    date: day,
    start_time: format("%02d:%02d", st_h, st_m),
    end_time:   format("%02d:%02d", end_h, end_m)
  )
end

orders = Order.all
puts "✅ #{orders.count} órdenes creadas"

# ==== Reseñas (sólo órdenes completadas) ====
puts "⭐ Creando reseñas..."

completed_orders = orders.select { |o| %w[completada].include?(o.status.to_s) }

completed_orders.each do |order|
  Review.create!(
    rating: rand(3.5..5.0).round(1),
    content: [
      "Excelente servicio, muy puntual y profesional. Lo recomiendo totalmente.",
      "Buena experiencia, aunque la comunicación podría mejorar un poco.",
      "Trabajo impecable, superó mis expectativas. Volvería a contratar sin dudarlo.",
      "Muy conforme con el resultado. Precio justo y buena calidad.",
      "Servicio correcto, llegó en horario y cumplió con lo acordado."
    ].sample,
    service: order.service,
    client: order.user,
    supplier: order.service.user
  )

  Review.create!(
    rating: rand(4.0..5.0).round(1),
    content: [
      "Cliente muy amable y respetuoso. Excelente comunicación.",
      "Todo perfecto, cliente cumplidor con los pagos y horarios.",
      "Muy buena experiencia, coordinación fluida y buen trato.",
      "Cliente responsable, recomendado para trabajar.",
      "Excelente cliente, todo se dio de manera profesional."
    ].sample,
    service: order.service,
    client: order.user,
    supplier: order.service.user
  )
end

puts "✅ #{Review.count} reseñas creadas"

puts "—"
puts "🧪 Día de prueba (supplier1): #{test_date} (#{%w[Dom Lun Mar Mié Jue Vie Sáb][test_date.wday]})"
puts "    Blackout    : 12:00–13:00"
puts "    Reserva 1   : Electricidad 10:00–11:00 (confirmed)"
puts "    Reserva 2   : Plomeria     15:00–16:30 (confirmed)"
puts "—"
puts "== Seed OK =="
