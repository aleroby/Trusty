class Message < ApplicationRecord
  belongs_to :chat
  validates :role, presence: true
  # Permit assistant messages to start empty so streaming can fill them in
  validates :content, presence: true, unless: -> { role == "assistant" }
end
