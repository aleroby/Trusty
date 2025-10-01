class ChangeColumnsInOrders < ActiveRecord::Migration[7.1]
  def change
    change_column :orders, :start_date_time, :datetime
    change_column :orders, :end_date_time, :datetime
  end
end
