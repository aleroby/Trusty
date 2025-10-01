class Review < ApplicationRecord
  belongs_to :service
  belongs_to :client, class_name: "User"
  belongs_to :supplier, class_name: "User"

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :content, presence: true, length: { minimum: 50 }

end
