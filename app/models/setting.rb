class Setting < ApplicationRecord
  belongs_to :brand

  validates :key, presence: true, uniqueness: { scope: :brand_id }
end
