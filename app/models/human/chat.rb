class Human::Chat < ApplicationRecord
  belongs_to :service
  belongs_to :order, optional: true
  belongs_to :client, class_name: "User"
  belongs_to :supplier, class_name: "User"

  has_many :messages, class_name: "Human::Message", dependent: :destroy, inverse_of: :human_chat

  STATUSES = %w[open archived].freeze

  validates :status, inclusion: { in: STATUSES }, allow_nil: true
end
