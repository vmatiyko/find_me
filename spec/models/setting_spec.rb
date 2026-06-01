# frozen_string_literal: true

require "rails_helper"

RSpec.describe Setting, type: :model do
  subject(:setting) { build(:setting) }

  describe "associations" do
    it { is_expected.to belong_to(:brand_user) }
    it { is_expected.to have_one(:brand).through(:brand_user) }
    it { is_expected.to have_one(:user).through(:brand_user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key) }

    it "validates one setting per brand-user pair" do
      brand_user = create(:brand_user)
      duplicate_setting = build(:setting, brand_user: brand_user)

      expect(duplicate_setting).not_to be_valid
      expect(duplicate_setting.errors[:brand_user_id]).to include("has already been taken")
    end

    it "allows the same user to have one setting for each brand" do
      user = create(:user)
      first_brand_user = create(:brand_user, user: user)
      second_brand_user = create(:brand_user, user: user)

      expect(first_brand_user.setting).to be_valid
      expect(second_brand_user.setting).to be_valid
      expect(user.settings).to contain_exactly(first_brand_user.setting, second_brand_user.setting)
    end
  end

  describe "database constraints" do
    it "rejects duplicate settings for the same brand-user pair" do
      brand_user = create(:brand_user)
      timestamp = Time.current

      expect do
        described_class.insert_all!(
          [
            {
              brand_user_id: brand_user.id,
              key: "custom",
              value: "enabled",
              created_at: timestamp,
              updated_at: timestamp
            }
          ]
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "value" do
    it "defaults to an empty string and cannot be null" do
      column = described_class.columns_hash.fetch("value")

      expect(column.null).to be(false)
      expect(column.default).to eq("")
      expect(build(:setting).value).to eq("enabled")
    end
  end
end
