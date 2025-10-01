class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Devise modules. Others available: :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  has_many :transactions, dependent: :destroy

  before_create :set_jti

  validates :email, presence: true, uniqueness: true

  private

  def set_jti
    self.jti ||= SecureRandom.uuid
  end
end
