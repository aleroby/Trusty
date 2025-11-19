class CreateHumanMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :human_messages do |t|
      t.references :human_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :human_messages, [:human_chat_id, :created_at]
  end
end
