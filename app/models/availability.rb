# app/models/availability.rb
class Availability < ApplicationRecord
  belongs_to :user

  validates :wday, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validate :end_after_start

  validate :no_overlap_same_day

  def no_overlap_same_day
    return if wday.nil? || start_time.nil? || end_time.nil?

    clash = Availability
      .where(user_id: user_id, wday: wday)
      .where.not(id: id)
      .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "Esa franja se superpone con otra.") if clash.exists?
  end

  private

  def end_after_start
    errors.add(:end_time, "debe ser mayor a la hora de inicio") if end_time <= start_time
  end
end
