# frozen_string_literal: true

require "rails_helper"

RSpec.describe Brand, type: :model do
  subject(:brand) { build(:brand) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates name uniqueness case-insensitively before the database constraint" do
      create(:brand, name: "Apple")

      duplicate_brand = build(:brand, name: "apple")

      expect(duplicate_brand).not_to be_valid
      expect(duplicate_brand.errors[:name]).to include("has already been taken")
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
