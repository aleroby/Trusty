class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  has_many :services #Usuario vendedor @current_user.services
  has_many :orders #Usuario comprador
  has_many :reviews
  has_one_attached :user_photo

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "formato inválido" }
  validates :phone, presence: true
  validates :address, presence: true

  before_create :set_default_role

  private
  def set_default_role
    self.role ||= "client"
  end
end
