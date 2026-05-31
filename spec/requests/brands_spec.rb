# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Brands", type: :request do
  describe "PATCH /brands/:id" do
    it "updates and returns the normalized brand name" do
      brand = create(:brand, name: "Original")

      patch brand_path(brand), params: { brand: { name: " Test ACME Brand " } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => brand.id,
        "name" => "acmebrand",
        "users_count" => 0
      )
      expect(brand.reload.name).to eq("acmebrand")
    end

    it "returns useful errors when the normalized name is invalid" do
      brand = create(:brand, name: "Original")

      patch brand_path(brand), params: { brand: { name: " test " } }, as: :json

      expect(response).to have_http_status(422)
      expect(response.parsed_body.fetch("errors")).to include("Name can't be blank")
      expect(brand.reload.name).to eq("original")
    end
  end
end
