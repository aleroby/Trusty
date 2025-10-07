class AddEmbeddingToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :embedding, :vector, limit: 1536
  end
end
