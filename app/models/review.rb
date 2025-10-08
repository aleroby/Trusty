class Review < ApplicationRecord
  belongs_to :service
  belongs_to :client, class_name: "User"
  belongs_to :supplier, class_name: "User"

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :content, presence: true, length: { minimum: 10 }

  enum target: { for_supplier: 0, for_client: 1 } # 👈

  # Scopes útiles
  scope :for_this_supplier,          ->(user_id)    { where(supplier_id: user_id, target: :for_supplier) }
  scope :for_this_service_supplier,  ->(service_id) { where(service_id: service_id, target: :for_supplier) }

  has_neighbors :embedding
  after_create :set_embedding, unless: :skip_embeddings?

  private

  def set_embedding
    embedding = RubyLLM.embed("Rating: #{rating}. Content: #{content}")
    update(embedding: embedding.vectors)
  end

  def skip_embeddings?
    Rails.env.test? || ENV["SEEDING"] == "1"
    rescue StandardError => e
    Rails.logger.warn("[Review#set_embedding] Embedding omitido: #{e.class} - #{e.message}")
    # Opcional: dejá nil o poné un vector neutro si lo exige tu código
    self.embedding = nil
  end

end
