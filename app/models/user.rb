class User < ApplicationRecord
  include NormalizesTextFields

  has_many :brand_users, dependent: :destroy
  has_many :brands, through: :brand_users
  has_many :settings, through: :brand_users

  normalizes_text_fields :first_name, :last_name, :email

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, email: true, allow_blank: true
end
