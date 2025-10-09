class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  has_many :pepes, class_name: "Service", foreign_key: "user_id"
  has_many :services #Usuario vendedor @current_user.services
  has_many :orders #Usuario comprador
  has_many :reviews_as_supplier, class_name: "Review", foreign_key: :supplier_id
  has_many :reviews_as_client,   class_name: "Review", foreign_key: :client_id
  has_one_attached :user_photo

  # AGREGADOS PARA AGENDA PROVEEDOR
  has_many :availabilities, dependent: :destroy
  has_many :blackouts, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "formato inválido" }
  validates :phone, presence: true
  validates :address, presence: true

  before_create :set_default_role

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def supplier_rating_avg
    reviews_as_supplier.for_supplier.average(:rating)&.to_f
  end

  def supplier_reviews_count
    reviews_as_supplier.for_supplier.count
  end

  def client_rating_avg
    reviews_as_client.for_client.average(:rating)&.to_f
  end

  def client_reviews_count
    reviews_as_client.for_client.count
  end

  has_neighbors :embedding
  after_create :set_embedding

  private
  def set_default_role
    self.role ||= "client"
  end

  def set_embedding
    embedding = RubyLLM.embed("Address: #{address}. Latitude: #{latitude}.
    Longitude: #{longitude}. Radius: #{radius}")
    update(embedding: embedding.vectors)
  end
end
