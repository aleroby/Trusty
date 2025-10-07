class Review < ApplicationRecord
  belongs_to :service
  belongs_to :client, class_name: "User"
  belongs_to :supplier, class_name: "User"

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :content, presence: true, length: { minimum: 10 }

  has_neighbors :embedding
  after_create :set_embedding

  private

  def set_embedding
    embedding = RubyLLM.embed("Rating: #{rating}. Content: #{content}")
    update(embedding: embedding.vectors)
  end
end
