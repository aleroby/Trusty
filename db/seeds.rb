require "date"
require "open-uri"
require "set"

# Evitar llamadas externas (embeddings) durante el seed
ENV["SEEDING"] = "1"

puts "🧹 Limpiando base de datos..."

# Orden correcto para no violar FKs
Review.destroy_all
Order.destroy_all
Availability.destroy_all
Blackout.destroy_all
Service.destroy_all
Message.destroy_all rescue nil
Chat.destroy_all    rescue nil
PgSearch::Document.destroy_all if defined?(PgSearch::Document)
ActiveStorage::Attachment.destroy_all
ActiveStorage::Blob.destroy_all
User.destroy_all

# Colecciones de trabajo
suppliers = []
clients   = []

# ======== Ayudantes ========

# Número aleatorio múltiplo de 1000 dentro del rango dado
def rand_thousand_in(range)
  min_k = (range.begin.to_i + 999) / 1000          # ceil(min / 1000)
  max_i = range.exclude_end? ? range.end.to_i - 1 : range.end.to_i
  max_k = max_i / 1000                              # floor(max / 1000)
  k = rand(min_k..max_k)
  k * 1000
end

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
  rand_thousand_in(range)
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

def gen_person(_i)
  first = %w[Agustín Felipe Facundo Nicolás Julieta Lucía Paula Antonella Florencia Carla
             Pedro Ramiro Gonzalo Ignacio Juan Pablo Diego Micaela Sol Valentina Candela
             Martina Emilia Camilo Bruno Joaquín Mateo Tomás Zoe Lara Jazmín Bianca Milagros].sample
  last = %w[Pérez Gómez Rodríguez Fernández López Díaz Martínez García Romero Torres
            Castro Herrera Silva Rojas Vega Morales Sánchez Navarro Moyano Ponce].sample
  [first, last]
end

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

# ===== 5 suppliers base (BA) =====
supplier1 = User.create!(
  first_name: "Carlos",
  last_name: "Mendoza",
  email: unique_email("carlos.mendoza@mail.com", used_emails),
  password: "123456",
  phone: "11-4567-8901",
  address: "Av. Santa Fe 3300, Buenos Aires",  # Palermo
  role: "supplier",
  radius: 5,
  latitude: -34.5945,
  longitude: -58.3974
); suppliers << supplier1

supplier2 = User.create!(
  first_name: "Andrea",
  last_name: "Gómez",
  email: unique_email("andrea.gomez@mail.com", used_emails),
  password: "123456",
  phone: "11-5678-9012",
  address: "Av. Córdoba 5500, Buenos Aires",   # Palermo Hollywood
  role: "supplier",
  radius: 2,
  latitude: -34.5889,
  longitude: -58.4242
); suppliers << supplier2

supplier3 = User.create!(
  first_name: "José",
  last_name: "Rodríguez",
  email: unique_email("jose.rodriguez@mail.com", used_emails),
  password: "123456",
  phone: "11-6789-0123",
  address: "Av. Cabildo 2000, Buenos Aires",   # Belgrano
  role: "supplier",
  radius: 6,
  latitude: -34.5614,
  longitude: -58.4569
); suppliers << supplier3

supplier4 = User.create!(
  first_name: "María",
  last_name: "Fernández",
  email: unique_email("maria.fernandez@mail.com", used_emails),
  password: "123456",
  phone: "11-7890-1234",
  address: "Av. Rivadavia 8000, Buenos Aires", # Flores
  role: "supplier",
  radius: 10,
  latitude: -34.6286,
  longitude: -58.4689
); suppliers << supplier4

supplier5 = User.create!(
  first_name: "Luis",
  last_name: "Sánchez",
  email: unique_email("luis.sanchez@mail.com", used_emails),
  password: "123456",
  phone: "11-8901-2345",
  address: "Av. Libertador 7500, Buenos Aires", # Núñez
  role: "supplier",
  radius: 15,
  latitude: -34.5442,
  longitude: -58.4644
); suppliers << supplier5

puts "👥 Creando suppliers (completando 30 BA + 30 MZA)..."

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
    radius: [5,10,15,20].sample,
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
    radius: [5,10,15,20].sample,
    latitude: lat,
    longitude: lon
  )
end

puts "✅ Total suppliers: #{User.where(role: 'supplier').count} (30 BA + 30 MZA)"

# ===== Servicios: cobertura de subcategorías y al menos 1 por supplier =====
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
    duration_minutes: [60,90,120,180].sample
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
      duration_minutes: [60,90,120,180].sample
    )
  end
end

puts "✅ Servicios asignados y cobertura de subcategorías en ambas ciudades"

# ===== Clientes (30 BA + 30 MZA) =====
puts "👥 Creando clientes (30 BA + 30 MZA)..."

# 30 BA
30.times do |i|
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

# 30 MZA
30.times do |i|
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

# ===== Agenda: disponibilidades y blackout =====
(1..5).each do |wday| # 1=Lun ... 5=Vie
  User.where(role: "supplier").find_each do |sup|
    sup.availabilities.create!(wday: wday, start_time: "09:00", end_time: "13:00")
    sup.availabilities.create!(wday: wday, start_time: "14:00", end_time: "18:00")
  end
end
puts "✅ Disponibilidades semanales creadas para todos los suppliers"

def next_weekday(from_date = Date.current)
  d = from_date
  d += 1.day while [0, 6].include?(d.wday) # saltear domingo(0) y sábado(6)
  d
end
test_date = next_weekday

supplier1.blackouts.create!(
  starts_at: Time.zone.local(test_date.year, test_date.month, test_date.day, 12, 0, 0),
  ends_at:   Time.zone.local(test_date.year, test_date.month, test_date.day, 13, 0, 0),
  reason: "Almuerzo (demo)"
)
puts "✅ Blackout 12:00–13:00 creado para supplier1 en #{test_date}"

# ===== Órdenes demo (2 confirmed en test_date para supplier1) =====
puts "📅 Creando órdenes de ejemplo..."

service_elec = supplier1.services.find_by(sub_category: "Electricidad") || supplier1.services.first
service_plom = supplier1.services.find_by(sub_category: "Plomeria")     || supplier1.services.last

Order.create!(
  user: clients.sample,
  service: service_elec,
  service_address: "Dirección del cliente",
  total_price: service_elec.price,
  status: "confirmed",
  date: test_date,
  start_time: "10:00",
  end_time:   "11:00"
)

Order.create!(
  user: clients.sample,
  service: service_plom,
  service_address: "Dirección del cliente",
  total_price: service_plom.price,
  status: "confirmed",
  date: test_date,
  start_time: "15:00",
  end_time:   "16:30"
)

orders = Order.all
puts "✅ #{orders.count} órdenes creadas (parciales de demo)"

# === Helpers de agenda SIN solapamientos ===
def time_on(date, hhmm)
  h, m = hhmm.split(":").map!(&:to_i)
  Time.zone.local(date.year, date.month, date.day, h, m, 0)
end

def overlaps?(a_start, a_end, b_start, b_end)
  a_start < b_end && b_start < a_end
end

def supplier_existing_orders_on(date, supplier_id)
  Order.joins(:service)
       .where(date: date, services: { user_id: supplier_id })
       .select(:start_time, :end_time)
end

def supplier_blackouts_on(date, supplier_id)
  day_start = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
  day_end   = day_start + 1.day
  Blackout.where(user_id: supplier_id)
          .where("starts_at < ? AND ends_at > ?", day_end, day_start)
          .select(:starts_at, :ends_at)
end

# slots posibles (cada 30’) dentro de availabilities del proveedor
def candidate_slots_for(service, date)
  supplier = service.user
  wday = date.cwday # 1..7 (seed usa 1..5)

  avs = supplier.availabilities.where(wday: wday)
  return [] if avs.empty?

  duration_min = service.duration_minutes
  existing = supplier_existing_orders_on(date, supplier.id).map do |o|
    [time_on(date, o.start_time.strftime("%H:%M")), time_on(date, o.end_time.strftime("%H:%M"))]
  end

  blks = supplier_blackouts_on(date, supplier.id).map { |b| [b.starts_at, b.ends_at] }

  slots = []
  avs.each do |av|
    av_start = time_on(date, av.start_time.strftime("%H:%M"))
    av_end   = time_on(date, av.end_time.strftime("%H:%M"))
    t = av_start
    step = 30.minutes
    while (t + duration_min.minutes) <= av_end
      st = t
      en = t + duration_min.minutes
      next_conf_blk = blks.any? { |(bs, be)| overlaps?(st, en, bs, be) }
      next_conf_ord = existing.any? { |(os, oe)| overlaps?(st, en, os, oe) }
      slots << [st, en] unless next_conf_blk || next_conf_ord
      t += step
    end
  end
  slots
end

# Busca fecha hábil ±15 días y devuelve un slot libre
def find_free_slot_for(service)
  attempts = 90
  attempts.times do
    date = Date.current + rand(-15..15).days
    next unless (1..5).include?(date.cwday)
    slots = candidate_slots_for(service, date)
    return [date, *slots.sample] unless slots.empty?
  end
  nil
end

def create_n_orders(n, status, clients)
  created = 0
  guard = 0
  while created < n && guard < n * 20
    guard += 1
    svc = Service.order("RANDOM()").first
    slot = find_free_slot_for(svc)
    next if slot.nil?

    date, st_dt, en_dt = slot
    cl = clients.sample

    Order.create!(
      user: cl,
      service: svc,
      service_address: cl.address,
      total_price: svc.price,
      status: status,
      date: date,
      start_time: st_dt.strftime("%H:%M"),
      end_time:   en_dt.strftime("%H:%M")
    )
    created += 1
  end
  if created < n
    puts "⚠️  Aviso: se pidieron #{n} órdenes #{status} pero sólo se pudieron crear #{created} sin solapamientos."
  end
end

# ====== GENERADOR CONTROLADO PARA LLEGAR A 200 ÓRDENES EXACTAS ======
target_total = 200
already_confirmed = Order.where(status: "confirmed").count
already_completed = Order.where(status: "completed").count
already_canceled  = Order.where(status: "canceled").count

need_completed = [120 - already_completed, 0].max
need_confirmed = [ 60 - already_confirmed, 0].max
need_canceled  = [ 20 - already_canceled , 0].max

create_n_orders(need_completed, "completed", clients)
create_n_orders(need_confirmed, "confirmed", clients)
create_n_orders(need_canceled,  "canceled",  clients)

missing = target_total - Order.count
create_n_orders([missing, 0].max, "completed", clients)

puts "✅ Totales finales de órdenes:"
puts "   completed: #{Order.where(status: 'completed').count}"
puts "   confirmed: #{Order.where(status: 'confirmed').count}"
puts "   canceled : #{Order.where(status: 'canceled').count}"
puts "   TOTAL    : #{Order.count}"

# ===== Reseñas (2 por cada completed) =====
puts "⭐ Creando reseñas..."

completed_orders = Order.where(status: "completed")

client_texts = [
  "Contraté el servicio para una reparación urgente y quedé muy conforme. Llegó a horario, evaluó rápido el problema y me explicó con claridad las alternativas. Trabajó prolijo, protegió el área y dejó todo limpio. El precio fue acorde y me emitió factura al instante.",
  "Excelente atención desde el primer contacto: respondió rápido, coordinamos día y franja horaria sin vueltas y cumplió a la perfección. Trajo materiales, sugirió mejoras y revisó el funcionamiento final. Muy profesional y amable. Lo volvería a contratar.",
  "Me gustó mucho la seriedad y el cuidado por los detalles. Verificó medidas, confirmó el presupuesto antes de empezar y mantuvo comunicación constante. El resultado final superó lo esperado y hasta dejó recomendaciones de mantenimiento preventivo.",
  "Trabajo impecable y cero complicaciones. Puntualidad, herramientas adecuadas y una actitud súper respetuosa en casa. Cubrió el piso, retiró residuos y probó todo antes de irse. La relación calidad-precio me pareció justa. Recomendado sin dudar.",
  "La coordinación fue simple y transparente. Llegó dentro del horario pautado, explicó el plan de trabajo y cumplió cada etapa. El acabado quedó prolijo y se notó experiencia. Además, respondió preguntas postservicio con muy buena predisposición.",
  "Quería destacar la claridad para presupuestar y la prolijidad en la ejecución. No hubo sorpresas: el monto final coincidió con lo acordado y el trabajo quedó sólido. Agradezco también la paciencia para explicar opciones y tiempos de secado.",
  "Muy buena experiencia: evaluó la instalación existente, detectó riesgos y propuso soluciones seguras. Trajo repuestos de calidad y dejó todo funcionando. Además, limpió el área y se llevó el material descartado. Trato cordial en todo momento.",
  "Se notó profesionalismo desde el primer minuto. Verificó tensión, midió consumos y documentó con fotos el antes y después. El resultado es prolijo y estético. Valoré mucho la puntualidad y el respeto por los espacios. Lo recomiendo totalmente.",
  "El servicio fue eficiente y sin vueltas. Respetó el presupuesto, trabajó con guantes y protectores, y revisó posibles filtraciones antes de cerrar. Me dejó consejos útiles para el uso diario y garantizó el trabajo por escrito. Excelente atención.",
  "Atención de primera: escuchó mi necesidad, propuso un plan realista y cumplió con los plazos. La terminación quedó pareja y sin detalles a corregir. Además, se ocupó de ordenar todo al finalizar. Muy buena comunicación y trato amable."
]

supplier_texts = [
  "Cliente muy respetuoso y organizado. Compartió fotos y detalles antes de la visita, facilitó acceso y estacionamiento, y estuvo atento a las recomendaciones. Pagó en tiempo y forma. Excelente comunicación y ambiente de trabajo, todo fluyó perfecto.",
  "La coordinación fue ágil: el cliente confirmó franja horaria, despejó el área y mantuvo el lugar ventilado. Recibí un brief claro y expectativas realistas. Pagó al finalizar, sin demoras. Muy buen trato, volvería a trabajar en ese domicilio.",
  "Trato cordial y claridad en los pedidos. El cliente estuvo presente para consultas clave, respetó los tiempos y brindó enchufes y luz de apoyo. La vivienda estaba ordenada, lo que agilizó el trabajo. Pago y comprobante sin complicaciones.",
  "Excelente predisposición: envió ubicación exacta, avisó al portero y preparó el espacio. Escuchó recomendaciones técnicas y aprobó cada etapa. El pago fue inmediato. Experiencia muy positiva, ojalá todos los servicios fueran así de prolijos.",
  "Cliente responsable y cuidadoso con los detalles. Acordamos alcance y presupuesto por escrito y lo respetó sin cambios de último momento. El área estaba despejada y limpia. Abonó como se pactó. Comunicación clara en todo momento.",
  "Muy buena experiencia: el cliente brindó información previa útil, aceptó sugerencias y mantuvo un trato amable. No hubo cancelaciones ni reprogramaciones. Proceso ágil, pago puntual y feedback constructivo al cierre del servicio.",
  "Profesionalidad del cliente notable. Tenía a mano garantías y manuales, lo que facilitó diagnósticos. Fue puntual, permitió trabajar sin interrupciones y realizó el pago vía transferencia con comprobante. Excelente colaboración.",
  "Todo resultó sencillo gracias a una comunicación clara. El cliente preparó el entorno, protegió sus muebles y respetó las normas de seguridad. Solicitó factura y la abonó al instante. Experiencia ordenada y muy recomendable.",
  "Cliente amable y confiable. Definimos prioridades, tiempos y alcance desde el inicio. Proporcionó enchufe y acceso al tablero cuando fue necesario. Pago dentro del horario pactado y recepción del trabajo sin objeciones. Muy buena interacción.",
  "Muy buena coordinación logística: compartió referencias para llegar, autorizó el ingreso y estuvo disponible para aprobar cambios menores. Mantuvo el área despejada y colaboró con pruebas finales. Pago correcto y trato excelente."
]

completed_orders.find_each do |order|
  # Review del CLIENTE → PROVEEDOR
  Review.create!(
    rating: rand(4.0..5.0).round(1),
    content: client_texts.sample,
    service: order.service,
    client:  order.user,             # quien contrata
    supplier: order.service.user,    # quien brinda el servicio
    target: :for_supplier            # enum hacia el proveedor
  )

  # Review del PROVEEDOR → CLIENTE
  Review.create!(
    rating: rand(4.0..5.0).round(1),
    content: supplier_texts.sample,
    service: order.service,
    client:  order.user,             # mismo cliente
    supplier: order.service.user,    # mismo proveedor
    target: :for_client              # enum hacia el cliente
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

# ===== Imágenes (2 por servicio de Electricidad) =====
electricity_images = [
  "https://images.unsplash.com/photo-1660330589693-99889d60181e?w=1200&q=80&auto=format",
  "https://plus.unsplash.com/premium_photo-1682086494759-b459f6eff2df?w=1200&q=80&auto=format",
  "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=1200&q=80&auto=format",
  "https://images.unsplash.com/photo-1657664066042-c59e5f84b7a8?w=1200&q=80&auto=format",
  "https://plus.unsplash.com/premium_photo-1682086495049-43a423baec15?w=1200&q=80&auto=format",
  "https://images.unsplash.com/photo-1660330589693-99889d60181e?w=1200&q=80&auto=format",
  "https://plus.unsplash.com/premium_photo-1664301437032-c210e558712c?w=1200&q=80&auto=format",
  "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=1200&q=80&auto=format"
]

services = Service.where(sub_category: "Electricidad").to_a
services.each_with_index do |service, i|
  idx1 = (2 * i) % electricity_images.length
  idx2 = (2 * i + 1) % electricity_images.length
  urls = [electricity_images[idx1], electricity_images[idx2]]

  service.images.purge if service.images.attached?

  attachments = urls.map.with_index(1) do |url, j|
    io = URI.open(url)
    { io: io, filename: "electricidad-#{service.id}-#{i+1}-#{j}.jpg", content_type: "image/jpeg" }
  end

  service.images.attach(attachments)
end

# ===== Imágenes (2 por servicio de Plomeria) =====

plomeria_images = [
  "https://plus.unsplash.com/premium_photo-1661884973994-d7625e52631a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjF8fHBsdW1iZXJzfGVufDB8fDB8fHww",
  "https://images.unsplash.com/photo-1676210134188-4c05dd172f89?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGxvbWVyJUMzJUFEYXxlbnwwfHwwfHx8MA%3D%3D",
  "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1620653713380-7a34b773fef8?q=80&w=945&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1542013936693-884638332954?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1521207418485-99c705420785?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1649959738550-ad6254b9bb7e?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
]

services = Service.where(sub_category: "Plomeria").to_a
services.each_with_index do |service, i|
  idx1 = (2 * i) % plomeria_images.length
  idx2 = (2 * i + 1) % plomeria_images.length
  urls = [plomeria_images[idx1], plomeria_images[idx2]]

  service.images.purge if service.images.attached?

  attachments = urls.map.with_index(1) do |url, j|
    io = URI.open(url)
    { io: io, filename: "plomeria-#{service.id}-#{i+1}-#{j}.jpg", content_type: "image/jpeg" }
  end

  service.images.attach(attachments)
end

# ===== Imágenes (2 por Cuidado de niños) =====

cuidado_ninos_images = [
  "https://images.unsplash.com/photo-1587323655395-b1c77a12c89a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjJ8fGN1aWRhZG8lMjBuaSVDMyVCMW9zfGVufDB8fDB8fHww",
  "https://images.unsplash.com/photo-1536825919521-ab78da56193b?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=1140&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1548425083-4261538dbca4?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?q=80&w=1172&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1650504148053-ae51b12dc1d4?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
]

services = Service.where(sub_category: "Cuidado de Niños").to_a
services.each_with_index do |service, i|
  idx1 = (2 * i) % plomeria_images.length
  idx2 = (2 * i + 1) % plomeria_images.length
  urls = [plomeria_images[idx1], plomeria_images[idx2]]

  service.images.purge if service.images.attached?

  attachments = urls.map.with_index(1) do |url, j|
    io = URI.open(url)
    { io: io, filename: "plomeria-#{service.id}-#{i+1}-#{j}.jpg", content_type: "image/jpeg" }
  end

  service.images.attach(attachments)
end

# Limpieza de flag de seed
ENV.delete("SEEDING")
