class Service < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :reviews

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

  private

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
    Service.all
      .by_category(params[:category])
      .by_sub_category(params[:sub_category])
      .by_date(params[:date])
      .by_start_time(params[:start_time])
      .by_end_time(params[:end_time])
      .by_price_max(params[:price_max])
      .by_location(params[:location])
  end

  # === Métodos para JS/HTML dinámico ===

  # def self.category_list
  #   distinct.pluck(:category).compact.sort
  # end

  # def self.subcategory_list
  #   distinct.pluck(:sub_category).compact.sort
  # end

  # def self.map_filter_for_js

  #     grouped = Service.group(:category, :sub_category).count
  #     grouped.each_with_object({}) do |((cat, sub), _), hash|
  #       hash[cat] ||= []
  #       hash[cat] << sub unless hash[cat].include?(sub)
  #     end

  # end

end
