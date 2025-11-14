class AddQuantityToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :quantity, :integer, default: 1, null: false
  end
end
