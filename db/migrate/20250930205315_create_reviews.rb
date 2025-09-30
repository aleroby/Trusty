class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.float :rating
      t.text :content
      t.references :service, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
