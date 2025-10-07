# 1. Duración por servicio (default 60')
class AddDurationToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :duration_minutes, :integer, null: false, default: 60
  end
end
