class Brand < ApplicationRecord
  include NormalizesTextFields

  has_many :brand_users, dependent: :destroy
  has_many :users, through: :brand_users
  has_many :settings, through: :brand_users

  normalizes_text_fields :name
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
