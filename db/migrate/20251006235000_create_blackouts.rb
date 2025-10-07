# 3. Bloqueos puntuales (excepciones)
class CreateBlackouts < ActiveRecord::Migration[7.1]
  def change
    create_table :blackouts do |t|
      t.references :user, null: false, foreign_key: true            # proveedor
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :reason
      t.timestamps
    end
    add_index :blackouts, [:user_id, :starts_at, :ends_at]
  end
end
