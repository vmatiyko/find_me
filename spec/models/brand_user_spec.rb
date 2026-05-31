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

  describe "default setting" do
    it "creates one setting for the brand-user pair" do
      expect { create(:brand_user) }
        .to change(Setting, :count).by(1)
    end

    it "creates the setting for the correct brand and user" do
      brand_user = create(:brand_user)

      setting = Setting.find_by!(brand: brand_user.brand, user: brand_user.user)

      expect(setting.key).to eq("default")
      expect(setting.value).to eq("")
    end

    it "does not create a duplicate setting when one already exists for the pair" do
      brand = create(:brand)
      user = create(:user)
      create(:setting, brand: brand, user: user)

      expect { create(:brand_user, brand: brand, user: user) }
        .not_to change(Setting, :count)
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

      expect(Setting.exists?(brand: other_brand_user.brand, user: user)).to be(true)
    end
  end
end
