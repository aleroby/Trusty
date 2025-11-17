class AddOrderToReviews < ActiveRecord::Migration[7.1]
  def change
    add_reference :reviews, :order, null: false, foreign_key: true
    add_index :reviews, [:order_id, :target], unique: true
  end
end

