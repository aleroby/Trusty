class RemoveColumnsFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :start_date_time, :datetime
    remove_column :orders, :end_date_time, :datetime
  end
end
