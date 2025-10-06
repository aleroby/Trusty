class AddColumnsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :date, :date
    add_column :orders, :start_time, :time
    add_column :orders, :end_time, :time
  end
end
