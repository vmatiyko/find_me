# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrandUser, type: :model do
  subject(:brand_user) { build(:brand_user) }

  describe "associations" do
    it { is_expected.to belong_to(:brand).counter_cache(:users_count) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it "validates user uniqueness within a brand" do
      existing_brand_user = create(:brand_user)
      duplicate_brand_user = build(
        :brand_user,
        brand: existing_brand_user.brand,
        user: existing_brand_user.user
      )

      expect(duplicate_brand_user).not_to be_valid
      expect(duplicate_brand_user.errors[:user_id]).to include("has already been taken")
    end
  end

  describe "database constraints" do
    it "rejects duplicate brand-user pairs" do
      existing_brand_user = create(:brand_user)
      timestamp = Time.current

      expect do
        described_class.insert_all!(
          [
            {
              brand_id: existing_brand_user.brand_id,
              user_id: existing_brand_user.user_id,
              created_at: timestamp,
              updated_at: timestamp
            }
          ]
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "counter cache" do
    it "increments brand users_count when created" do
      brand = create(:brand)

      expect { create(:brand_user, brand: brand) }
        .to change { brand.reload.users_count }.by(1)
    end

    it "decrements brand users_count when destroyed" do
      brand_user = create(:brand_user)
      brand = brand_user.brand

      expect { brand_user.destroy! }
        .to change { brand.reload.users_count }.by(-1)
    end
  end
end
