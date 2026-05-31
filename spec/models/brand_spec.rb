# frozen_string_literal: true

require "rails_helper"

RSpec.describe Brand, type: :model do
  subject(:brand) { build(:brand) }

  describe "associations" do
    it { is_expected.to have_many(:settings).dependent(:destroy) }
    it { is_expected.to have_many(:brand_users).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:brand_users) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates name uniqueness case-insensitively before the database constraint" do
      create(:brand, name: "Apple")

      duplicate_brand = build(:brand, name: "apple")

      expect(duplicate_brand).not_to be_valid
      expect(duplicate_brand.errors[:name]).to include("has already been taken")
    end
  end

  describe "normalization" do
    it "normalizes name before validation" do
      brand = build(:brand, name: " Test ACME Brand ")

      brand.validate

      expect(brand.name).to eq("acmebrand")
    end

    it "rejects names that normalize to blank" do
      brand = build(:brand, name: " Test ")

      expect(brand).not_to be_valid
      expect(brand.errors[:name]).to include("can't be blank")
    end
  end

  describe "users_count" do
    it "defaults to zero and cannot be null" do
      column = described_class.columns_hash.fetch("users_count")

      expect(column.null).to be(false)
      expect(column.default.to_i).to eq(0)
      expect(build(:brand).users_count).to eq(0)
    end
  end
end
