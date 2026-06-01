class BrandUser < ApplicationRecord
  belongs_to :brand, counter_cache: :users_count
  belongs_to :user
  has_one :setting, dependent: :destroy, inverse_of: :brand_user, autosave: true

  before_validation :build_default_setting, on: :create

  validates :user_id, uniqueness: { scope: :brand_id }

  private

  def build_default_setting
    build_setting(key: "default", value: "") unless setting
  end
end
