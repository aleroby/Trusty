class Order < ApplicationRecord
  belongs_to :service
  belongs_to :user

  has_many :reviews, dependent: :destroy
  has_one :supplier_review, -> { for_supplier }, class_name: "Review"
  has_one :client_review,   -> { for_client },   class_name: "Review"

  STATUS_LIST = ["pending", "confirmed", "completed", "canceled"]

  validates :status, presence: true, inclusion: { in: STATUS_LIST }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  # --------------------HELPERS PARA REVIEWS---------------------------

  def ends_at
    return unless date && end_time
    Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.min)
  end

  def finished?
    ends_at.present? && Time.zone.now >= ends_at
  end

  def reviewable_by?(user)
    return false unless finished?
    if user == self.user
      supplier_review.blank?
    elsif user == service.user
      client_review.blank?
    else
      false
    end
  end

  # --------------------BLOQUE AGENDA PROVEEDOR---------------------------

  validates :date, :start_time, presence: true
  validate  :end_time_presence
  validate  :no_overlap_with_supplier_confirmed_orders

  before_validation :set_end_time_from_service, if: -> { service.present? && start_time.present? && end_time.blank? }

  scope :for_supplier, ->(user_id) { joins(:service).where(services: { user_id: user_id }) }

  private

  def set_end_time_from_service
    total_minutes = service.duration_minutes.to_i * (quantity || 1)
    self.end_time = (start_time + total_minutes.minutes).change(sec: 0)
  end

  def end_time_presence
    errors.add(:end_time, "no puede ser nula") if end_time.blank?
  end

  # Bloquea al nivel de proveedor (no sólo del servicio)
  def no_overlap_with_supplier_confirmed_orders
    return if date.blank? || start_time.blank? || end_time.blank? || service.nil?

    supplier_id = service.user_id
    confirmed_statuses = %w[confirmed] # ajusta a tus estados

    overlapping = Order
      .joins(:service)
      .where(services: { user_id: supplier_id })
      .where(date: date)
      .where(status: confirmed_statuses)
      .where.not(id: id) # ignorar la propia si es update
      .where(<<~SQL, start_time: start_time, end_time: end_time)
        (start_time < :end_time) AND (end_time > :start_time)
      SQL

    if overlapping.exists?
      errors.add(:base, "El proveedor ya tiene una reserva en ese horario.")
    end
  end

end
