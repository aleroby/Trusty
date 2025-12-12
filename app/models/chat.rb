class Chat < ApplicationRecord
  belongs_to :user
  # Mantén los mensajes en orden cronológico ascendente
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy
  validates :title, presence: true
end
