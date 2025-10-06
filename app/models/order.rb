class Order < ApplicationRecord
  belongs_to :service
  belongs_to :user

  status_list = ["pendiente", "confirmada", "completada", "cancelada"]

  validates :status, presence: true, inclusion: { in: status_list }
end
