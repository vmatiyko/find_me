# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateBrand do
  describe ".result" do
    it "updates and exposes the brand" do
      brand = create(:brand, name: "Original")

      result = described_class.result(
        brand_id: brand.id,
        attributes: { name: " Test ACME Brand " }
      )

      expect(result).to be_success
      expect(result.brand).to eq(brand)
      expect(result.brand.name).to eq("acmebrand")
      expect(brand.reload.name).to eq("acmebrand")
    end

    it "returns validation errors without updating the brand" do
      brand = create(:brand, name: "Original")

      result = described_class.result(
        brand_id: brand.id,
        attributes: { name: " test " }
      )

      expect(result).to be_failure
      expect(result.error_messages).to include("Name can't be blank")
      expect(brand.reload.name).to eq("original")
    end
  end
end
