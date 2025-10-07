# 2. Disponibilidad semanal por proveedor
class CreateAvailabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :availabilities do |t|
      t.references :user, null: false, foreign_key: true           # proveedor
      t.integer :wday, null: false                                  # 0=domingo ... 6=sábado
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.timestamps
    end
    add_index :availabilities, [:user_id, :wday]
  end
end
