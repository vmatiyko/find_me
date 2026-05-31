class Brand < ApplicationRecord
  include NormalizesTextFields

  has_many :settings, dependent: :destroy
  has_many :brand_users, dependent: :destroy
  has_many :users, through: :brand_users

  normalizes_text_fields :name

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
