# frozen_string_literal: true

require "rails_helper"

RSpec.describe Setting, type: :model do
  subject(:setting) { build(:setting) }

  describe "associations" do
    it { is_expected.to belong_to(:brand) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key).scoped_to(:brand_id) }
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
