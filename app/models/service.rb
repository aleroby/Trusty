class Service < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :reviews

  has_many_attached :images

  CATEGORIAS_PERMITIDAS = [ "Jardinería", "Plomería", "Electricidad", "Peluquería a domicilio", "Limpieza a domicilio", "Cuidado de niños" ]
  SUB_CATEGORIAS_PERMITIDAS = [ "Corte de césped", "Reparación de canillas", "Instalación de lámparas", "Corte de cabello", "Limpieza profunda", "Niñera" ]

  validates :category, presence: true, inclusion: { in: CATEGORIAS_PERMITIDAS, message: "no es una categoría válida" }
  validates :sub_category, presence: true, inclusion: { in: SUB_CATEGORIAS_PERMITIDAS, message: "no es una categoría válida" }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

end
