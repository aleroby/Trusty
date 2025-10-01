class Service < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :reviews

  CATEGORIAS_PERMITIDAS = []
  SUB_CATEGORIAS_PERMITIDAS = []

  validates :category, presence: true, inclusion: { in: CATEGORIAS_PERMITIDAS, message: "no es una categoría válida" }
  validates :sub_category, presence: true, inclusion: { in: SUB_CATEGORIAS_PERMITIDAS, message: "no es una categoría válida" }
  validates :description, presence: true, length: { minimum: 200 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

end
