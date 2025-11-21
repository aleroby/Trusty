class Human::Message < ApplicationRecord
  belongs_to :human_chat, class_name: "Human::Chat", inverse_of: :messages
  belongs_to :user

  validates :content, presence: true
end
