# frozen_string_literal: true

require "rails_helper"

RSpec.describe Setting, type: :model do
  subject(:setting) { build(:setting) }

  describe "associations" do
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:brand_id) }

    it "allows the same user to have one setting for each brand" do
      user = create(:user)
      create(:setting, user: user)
      setting_for_another_brand = build(:setting, user: user)

      expect(setting_for_another_brand).to be_valid
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
              brand_id: brand_user.brand_id,
              user_id: brand_user.user_id,
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
