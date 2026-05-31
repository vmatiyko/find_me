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
end
