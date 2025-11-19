class ChangeOrderNullOnHumanChats < ActiveRecord::Migration[7.1]
  def change
    change_column_null :human_chats, :order_id, true
  end
end
