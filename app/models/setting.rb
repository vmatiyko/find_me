class Setting < ApplicationRecord
  belongs_to :brand_user, inverse_of: :setting
  has_one :brand, through: :brand_user
  has_one :user, through: :brand_user

  validates :key, presence: true
  validates :brand_user_id, uniqueness: true, allow_nil: true
end
