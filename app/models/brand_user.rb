class BrandUser < ApplicationRecord
  belongs_to :brand, counter_cache: :users_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :brand_id }
end
