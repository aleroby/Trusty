# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# db/seeds.rb
require "open-uri"

puts " Iniciando seed "


#  Datos

CATEGORIES = [
  {
    category: "Jardinería",
    sub_categories: ["Corte de césped"],
    image_url: "https://plus.unsplash.com/premium_photo-1682098326871-95eac6cf4f25?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bGF3biUyMG1vd2luZ3xlbnwwfHwwfHx8MA%3D%3D"
  },
  {
    category: "Plomería",
    sub_categories: ["Reparación de canillas"],
    image_url: "https://plus.unsplash.com/premium_photo-1750594941118-145ef7a1791d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHBsdW1iaW5nJTIwdGFwJTIwcmVwYWlyfGVufDB8fDB8fHww"
  },
  {
    category: "Electricidad",
    sub_categories: ["Instalación de lámparas"],
    image_url: "https://plus.unsplash.com/premium_photo-1726729480407-9ee5e3fab324?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZWxlY3RyaWMlMjBsYW1wJTIwaW5zdGFsbHxlbnwwfHwwfHx8MA%3D%3D"
  },
  {
    category: "Peluquería a domicilio",
    sub_categories: ["Corte de cabello"],
    image_url: "https://images.unsplash.com/photo-1621550508336-e1576b4ae59b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTB8fGhhaXJjdXQlMjBob21lfGVufDB8fDB8fHww"
  },
  {
    category: "Limpieza a domicilio",
    sub_categories: ["Limpieza profunda"],
    image_url: "https://images.unsplash.com/photo-1758273238370-3bc08e399620?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGRlZXAlMjBjbGVhbmluZyUyMHNlcnZpY2V8ZW58MHx8MHx8fDA%3D"
  },
  {
    category: "Cuidado de niños",
    sub_categories: ["Niñera"],
    image_url: "https://plus.unsplash.com/premium_photo-1711381022968-b5e139df4174?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8YmFieXNpdHRlcnxlbnwwfHwwfHx8MA%3D%3D"
  }
].freeze

ORDER_STATUSES = ["pending", "accepted", "completed"].freeze


#  Usuarios

puts " Creando usuarios de ejemplo..."

supplier = User.find_or_create_by!(email: "proveedor@seed.com") do |user|
  user.first_name = "Proveedor"
  user.last_name  = "Semilla"
  user.password   = "password"
  user.phone      = "111111111"
  user.address    = "Calle Proveedor 123"
  user.role       = "supplier"
end

unless supplier.user_photo.attached?
  avatar = URI.open("https://i.pravatar.cc/300?u=supplier")
  supplier.user_photo.attach(io: avatar, filename: "supplier.jpg", content_type: "image/jpg")
end

clients = (1..2).map do |i|
  User.find_or_create_by!(email: "cliente#{i}@seed.com") do |user|
    user.first_name = "Cliente#{i}"
    user.last_name  = "Ejemplo"
    user.password   = "password"
    user.phone      = "22222222#{i}"
    user.address    = "Calle Cliente #{i}"
    user.role       = "client"
  end.tap do |client|
    unless client.user_photo.attached?
      avatar = URI.open("https://i.pravatar.cc/300?u=cliente#{i}")
      client.user_photo.attach(io: avatar, filename: "client#{i}.jpg", content_type: "image/jpg")
    end
  end
end


# Servicios
puts " Creando servicios..."

CATEGORIES.each do |cat|
  service = Service.find_or_create_by!(
    category: cat[:category],
    sub_category: cat[:sub_categories].first,
    user: supplier
  ) do |s|
    s.description = "Servicio de #{cat[:category]} especializado en #{cat[:sub_categories].first}. " * 5
    s.price       = rand(1500..4000)
    s.published   = true
  end


  if cat[:image_url].present? && !service.images.attached?
    file = URI.open(cat[:image_url])
    service.images.attach(
      io: file,
      filename: "#{cat[:category].parameterize}.jpg",
      content_type: "image/jpg"
    )
  end
end


# Órdenes

puts " Creando órdenes..."

clients.each do |client|
  Service.all.sample(2).each do |service|
    Order.find_or_create_by!(
      user: client,
      service: service,
      service_address: client.address
    ) do |order|
      order.total_price       = service.price
      order.start_date_time   = Time.now - rand(1..5).days
      order.end_date_time     = order.start_date_time + rand(1..3).hours
      order.status            = ORDER_STATUSES.sample
    end
  end
end


#  Reviews de ejemplo

puts " Creando reviews..."

Order.all.each do |order|
  Review.find_or_create_by!(
    client: order.user,
    service: order.service,
    supplier: order.service.user
  ) do |review|
    review.rating  = rand(3..5)
    review.content = "Excelente servicio de #{order.service.category}, puntual y confiable. " * 2
  end
end

puts " Seed completado "

