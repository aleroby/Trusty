class Human::Chat < ApplicationRecord
  belongs_to :service
  belongs_to :order, optional: true
  belongs_to :client, class_name: "User"
  belongs_to :supplier, class_name: "User"

  has_many :messages, class_name: "Human::Message", dependent: :destroy, inverse_of: :human_chat

  STATUSES = %w[open archived].freeze

  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  def unread_for?(user)
    unread_messages_for(user).exists?
  end

  def mark_as_read_for(user)
    unread_messages_for(user).update_all(read_at: Time.current)
  end

  private

  def unread_messages_for(user)
    messages.where(read_at: nil).where.not(user: user)
  end
end
