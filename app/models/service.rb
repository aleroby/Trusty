class Service < ApplicationRecord
  belongs_to :user
  has_many :orders  
  has_many :supplier_reviews, -> { where(target: :for_supplier) }, class_name: "Review"

  has_neighbors :embedding
  after_create :set_embedding, unless: :skip_embeddings?

  # AGREGADO PARA AGENDA PROVEEDOR
  SLOT_STEP_MINUTES = 30

  # Multisearch PG Search
  include PgSearch::Model
  multisearchable against: [:category, :description, :sub_category]

  has_many_attached :images

  CATEGORIES = {
    "Hogar" => ["Control de Plagas", "Electricidad", "Jardinería", "Limpieza", "Planchado", "Plomeria"],
    "Cuidados" => ["Cuidado de niños", "Cuidado de ancianos"],
    "Estética" => ["Peluquería", "Maquillaje", "Depilación", "Estética Facial", "Manos y Pies"],
    "Wellness" => ["Clases de Yoga", "Masajes", "Clases de Pilates", "Clases de Meditacion"],
    "Entrenamiento" => ["Personal Trainer", "Funcional", "Calistenia", "Boxeo"],
    "Clases" => ["Idiomas", "Música", "Programación"]
  }.freeze

  # Validaciones
  validates :category, presence: true, inclusion: { in: ->(_) { category_list } }
  validates :sub_category, presence: true
  validate  :sub_category_must_belong_to_category

  validates :description, presence: true, length: { minimum: 10 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Estructura: "Categoría" => [subcategorías...]

  # Helpers para el formulario
  def self.category_list
    CATEGORIES.keys
  end

  def self.subcategory_list(category = nil)
    return CATEGORIES[category] || [] if category.present?
    CATEGORIES.values.flatten.uniq
  end

  # Para pasar el mapa completo al front (Stimulus)
  def self.map_for_js
    CATEGORIES
  end

  # --------------- INICIO BLOQUE PARA AGENDA PROVEEDOR--------------------------

  # Devuelve un array de Time (horas de inicio disponibles) para una fecha dada
  def available_slots(date)
    supplier = user
    return [] if supplier.availabilities.empty?

    wday = date.wday
    windows = supplier.availabilities.where(wday: wday)
    return [] if windows.blank?

    # 1) slots brutos dentro de la grilla del día
    slots = windows.flat_map do |win|
      slots_in_window(date, win.start_time, win.end_time, duration_minutes, SLOT_STEP_MINUTES)
    end

    # 2) restar bloqueos puntuales del proveedor
    slots = subtract_blackouts(slots, supplier.blackouts, date, duration_minutes)

    # 3) restar órdenes confirmadas del proveedor (en cualquiera de sus servicios)
    slots = subtract_orders(slots, supplier, date, duration_minutes)

    # 4) (Opcional) si querés no ofrecer slots “en el pasado” para hoy
    if date == Date.current
      slots = slots.select { |t| t > Time.current }
    end

    slots
  end

  private

  def slots_in_window(date, start_t, end_t, duration_min, step_min)
    day = date
    # construir tiempos absolutos para ese día
    from = Time.zone.local(day.year, day.month, day.day, start_t.hour, start_t.min, 0)
    to   = Time.zone.local(day.year, day.month, day.day, end_t.hour,   end_t.min,   0)

    res = []
    cursor = from
    while (cursor + duration_min.minutes) <= to
      res << cursor
      cursor += step_min.minutes
    end
    res
  end

  def subtract_blackouts(slots, blackouts, date, duration_min)
    return slots if blackouts.blank?

    day_range = date.beginning_of_day..date.end_of_day
    relevant = blackouts.where("(starts_at, ends_at) OVERLAPS (?, ?)", day_range.begin, day_range.end)

    slots.reject do |start_at|
      end_at = start_at + duration_min.minutes
      relevant.any? do |b|
        (start_at < b.ends_at) && (end_at > b.starts_at)
      end
    end
  end

  def subtract_orders(slots, supplier, date, duration_min)
    # Órdenes confirmadas del proveedor, en cualquiera de sus servicios, ese día
    confirmed_statuses = %w[confirmed] # ajusta a tus estados
    supplier_service_ids = supplier.services.select(:id)

    same_day_orders = Order
      .where(service_id: supplier_service_ids)
      .where(date: date)
      .where(status: confirmed_statuses)

    slots.reject do |start_at|
      end_at = start_at + duration_min.minutes
      same_day_orders.any? do |o|
        o_start = Time.zone.local(date.year, date.month, date.day, o.start_time.hour, o.start_time.min, 0)
        o_end   = Time.zone.local(date.year, date.month, date.day, o.end_time.hour,   o.end_time.min,   0)
        (start_at < o_end) && (end_at > o_start)
      end
    end
  end

  # ------------------FIN BLOQUE AGENDA PROVEEDOR--------------------------

  def set_embedding
    text = <<~TEXT
      Category: #{category}
      Sub-category: #{sub_category}
      Description: #{description}
      Price: $#{price}
    TEXT
    embedding = RubyLLM.embed(text)
    update(embedding: embedding.vectors)
  end

  def skip_embeddings?
    Rails.env.test? || ENV["SEEDING"] == "1"
    rescue StandardError => e
    Rails.logger.warn("[Review#set_embedding] Embedding omitido: #{e.class} - #{e.message}")
    # Opcional: dejá nil o poné un vector neutro si lo exige tu código
    self.embedding = nil
  end

  def sub_category_must_belong_to_category
    return if category.blank? || sub_category.blank?
    allowed = self.class.subcategory_list(category)
    errors.add(:sub_category, "no corresponde a la categoría seleccionada") unless allowed.include?(sub_category)
  end

  # Scopes para filtros
  scope :by_category, -> (cat) {
    where(category: cat) if cat.present?
  }

  scope :by_sub_category, -> (sub_cat) {
    where(sub_category: sub_cat) if sub_cat.present?
  }

  scope :by_date, -> (date) {
    where(date: date) if date.present?
  }

  scope :by_start_time, -> (time) {
    where("start_time >= ?", time) if time.present?
  }

  scope :by_end_time, -> (time) {
    where("end_time <= ?", time) if time.present?
  }

  scope :by_price_max, -> (price) {
    where("price <= ?", price) if price.present?
  }

  scope :by_location, -> (loc) {
    where("location ILIKE ?", "%#{loc}%") if loc.present?
  }

  # === Método principal de filtrado ===
  def self.filter(params)
  services = Service.all
    .by_category(params[:category])
    .by_sub_category(params[:sub_category])
    .by_date(params[:date])
    .by_start_time(params[:start_time])
    .by_end_time(params[:end_time])
    .by_price_max(params[:price_max])
    # .by_location(params[:location])

  # Si hay dirección, filtra por radio de proveedores
  if params[:location].present?
    geo = Geocoder.search(params[:location]).first
    if geo
      client_coords = [geo.latitude, geo.longitude]
      supplier_ids = User.where(role: "supplier").where.not(radius: nil).geocoded.select do |supplier|
        distance = Geocoder::Calculations.distance_between(
          [supplier.latitude, supplier.longitude],
          client_coords
        )
        distance <= supplier.radius
      end.map(&:id)
      services = services.where(user_id: supplier_ids)
    end
  end

  services
  end
end
