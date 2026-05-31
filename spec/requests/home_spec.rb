# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "renders a brand-name autosave input" do
      brand = create(:brand, name: "Acme")

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Brand dashboard")
      expect(response.body).to include("Brand name")
      expect(response.body).to include("data-controller=\"autosave\"")
      expect(response.body).to include("data-autosave-url-value=\"#{brand_path(brand)}\"")
      expect(response.body).to include("submit-&gt;autosave#submit")
      expect(response.body).to include("value=\"acme\"")
    end

    it "creates a default brand when none exists" do
      expect { get root_path }.to change(Brand, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(Brand.first.name).to eq("default")
    end

    it "renders brand users, users_count, create fields, and remove controls" do
      brand_user = create(:brand_user)
      brand = brand_user.brand
      user = brand_user.user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Users count:")
      expect(response.body).to include(brand.users_count.to_s)
      expect(response.body).to include("First name")
      expect(response.body).to include("Last name")
      expect(response.body).to include("Email")
      expect(response.body).to include("Add user")
      expect(response.body).to include(user.first_name)
      expect(response.body).to include(user.last_name)
      expect(response.body).to include(user.email)
      expect(response.body).to include("Remove")
      expect(response.body).to include(brand_user_path(brand, user))
      expect(response.body).to include("data-turbo=\"false\"")
    end

    it "renders the brand list and selected brand settings" do
      first_brand = create(:brand, name: "First Brand")
      selected_brand_user = create(:brand_user, brand: create(:brand, name: "Second Brand"))
      selected_brand = selected_brand_user.brand
      selected_user = selected_brand_user.user

      get root_path(brand_id: selected_brand.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("All Brands")
      expect(response.body).to include(first_brand.name)
      expect(response.body).to include(selected_brand.name)
      expect(response.body).to include("Current brand: #{selected_brand.name}")
      expect(response.body).to include("Settings")
      expect(response.body).to include("default")
      expect(response.body).to include(selected_user.email)
      expect(response.body).to include("empty")
    end
  end
end
