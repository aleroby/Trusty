class Order < ApplicationRecord
  belongs_to :service
  belongs_to :user

  status_list = ["pending", "confirmed", "completed", "canceled"]

  validates :status, presence: true, inclusion: { in: status_list }

  # --------------------BLOQUE AGENDA PROVEEDOR---------------------------

  validates :date, :start_time, presence: true
  validate  :end_time_presence
  validate  :no_overlap_with_supplier_confirmed_orders

  before_validation :set_end_time_from_service, if: -> { service.present? && start_time.present? && end_time.blank? }

  scope :for_supplier, ->(user_id) { joins(:service).where(services: { user_id: user_id }) }

  private

  def set_end_time_from_service
    self.end_time = (start_time + service.duration_minutes.minutes).change(sec: 0)
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
