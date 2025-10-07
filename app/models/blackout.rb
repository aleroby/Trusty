# app/models/blackout.rb
class Blackout < ApplicationRecord
  belongs_to :user
  validate :ends_after_starts

  private

  def ends_after_starts
    errors.add(:ends_at, "debe ser posterior") if ends_at <= starts_at
  end
end
