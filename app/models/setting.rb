class Setting < ApplicationRecord
  belongs_to :brand
  belongs_to :user

  validates :key, presence: true
  validates :user_id, uniqueness: { scope: :brand_id }
end
