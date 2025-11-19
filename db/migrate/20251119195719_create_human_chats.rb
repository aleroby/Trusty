class CreateHumanChats < ActiveRecord::Migration[7.1]
  def change
    create_table :human_chats do |t|
      t.references :service, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.string :status
      t.datetime :last_message_at

      t.timestamps
    end
  end
end
