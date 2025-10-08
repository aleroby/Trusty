class AddTargetToReviews < ActiveRecord::Migration[7.1]
  def up
    add_column :reviews, :target, :integer, null: false, default: 0
    add_index  :reviews, [:service_id, :target]
    add_index  :reviews, [:supplier_id, :target]

    execute <<~SQL
      UPDATE reviews SET target = 0; -- 0 = for_supplier
    SQL
  end

  def down
    remove_index  :reviews, [:supplier_id, :target]
    remove_index  :reviews, [:service_id, :target]
    remove_column :reviews, :target
  end
end
