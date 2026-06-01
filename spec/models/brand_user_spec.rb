# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrandUser, type: :model do
  subject(:brand_user) { build(:brand_user) }

  describe "associations" do
    it { is_expected.to belong_to(:brand).counter_cache(:users_count) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:setting).dependent(:destroy) }
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

  describe "default setting" do
    it "creates one setting for the brand-user pair" do
      expect { create(:brand_user) }
        .to change(Setting, :count).by(1)
    end

    it "creates the setting for the correct brand and user" do
      brand_user = create(:brand_user)

      setting = brand_user.setting

      expect(setting.brand_user).to eq(brand_user)
      expect(setting.brand).to eq(brand_user.brand)
      expect(setting.user).to eq(brand_user.user)
      expect(setting.key).to eq("default")
      expect(setting.value).to eq("")
    end

    it "destroys the setting when the brand-user pair is destroyed" do
      brand_user = create(:brand_user)

      expect { brand_user.destroy! }
        .to change(Setting, :count).by(-1)
    end

    it "keeps settings for the same user on other brands" do
      user = create(:user)
      brand_user = create(:brand_user, user: user)
      other_brand_user = create(:brand_user, user: user)

      expect { brand_user.destroy! }
        .to change(Setting, :count).by(-1)

      expect(other_brand_user.reload.setting).to be_present
    end
  end
end
