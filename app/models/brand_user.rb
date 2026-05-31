class BrandUser < ApplicationRecord
  belongs_to :brand, counter_cache: :users_count
  belongs_to :user

  after_create :create_default_setting
  after_destroy :destroy_default_setting

  validates :user_id, uniqueness: { scope: :brand_id }

  private

  def create_default_setting
    Setting.find_or_create_by!(brand: brand, user: user) do |setting|
      setting.key = "default"
      setting.value = ""
    end
  end

  def destroy_default_setting
    Setting.find_by(brand: brand, user: user)&.destroy!
  end
end
