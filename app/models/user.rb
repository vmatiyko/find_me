class User < ApplicationRecord
  has_many :brand_users, dependent: :destroy
  has_many :brands, through: :brand_users

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
end
