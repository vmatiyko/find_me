# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Brand users", type: :request do
  describe "POST /brands/:brand_id/users" do
    it "creates a normalized user and associates it with the brand" do
      brand = create(:brand)

      expect do
        post brand_users_path(brand), params: {
          user: {
            first_name: " Test Ada ",
            last_name: " Lovelace ",
            email: " Test ADA @ Example.com "
          }
        }
      end.to change(User, :count).by(1)
        .and change { brand.reload.users_count }.by(1)
        .and change(Setting, :count).by(1)

      user = brand.users.first

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(user.first_name).to eq("ada")
      expect(user.last_name).to eq("lovelace")
      expect(user.email).to eq("ada@example.com")
      expect(Setting.find_by!(brand: brand, user: user).key).to eq("default")
    end

    it "reuses an existing user by normalized email" do
      brand = create(:brand)
      existing_user = create(:user, email: "ada@example.com")

      expect do
        post brand_users_path(brand), params: {
          user: {
            first_name: "Different",
            last_name: "Name",
            email: " Test ADA @ Example.com "
          }
        }
      end.to change(User, :count).by(0)
        .and change(BrandUser, :count).by(1)

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(brand.reload.users).to include(existing_user)
    end

    it "does not create records when user fields normalize to blank" do
      brand = create(:brand)
      original_counts = {
        users: User.count,
        brand_users: BrandUser.count,
        settings: Setting.count,
        users_count: brand.users_count
      }

      post brand_users_path(brand), params: {
        user: {
          first_name: "test",
          last_name: "test",
          email: "test"
        }
      }

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(flash[:alert]).to include("First name can't be blank")
      expect(User.count).to eq(original_counts[:users])
      expect(BrandUser.count).to eq(original_counts[:brand_users])
      expect(Setting.count).to eq(original_counts[:settings])
      expect(brand.reload.users_count).to eq(original_counts[:users_count])
    end

    it "does not create a duplicate membership for the same brand and user" do
      brand_user = create(:brand_user)
      brand = brand_user.brand
      user = brand_user.user
      original_counts = {
        users: User.count,
        brand_users: BrandUser.count,
        settings: Setting.count,
        users_count: brand.users_count
      }

      post brand_users_path(brand), params: {
        user: {
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email
        }
      }

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(flash[:alert]).to include("User has already been taken")
      expect(User.count).to eq(original_counts[:users])
      expect(BrandUser.count).to eq(original_counts[:brand_users])
      expect(Setting.count).to eq(original_counts[:settings])
      expect(brand.reload.users_count).to eq(original_counts[:users_count])
    end

    it "renders a single dashboard after redirecting from create" do
      brand = create(:brand)

      post brand_users_path(brand), params: {
        user: {
          first_name: "Grace",
          last_name: "Hopper",
          email: "grace@example.com"
        }
      }
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body.scan("Brand dashboard").size).to eq(1)
      expect(response.body).to include("grace@example.com")
    end
  end

  describe "DELETE /brands/:brand_id/users/:id" do
    it "removes the user from the brand and decrements users_count" do
      brand_user = create(:brand_user)
      brand = brand_user.brand
      user = brand_user.user

      expect do
        delete brand_user_path(brand, user)
      end.to change(BrandUser, :count).by(-1)
        .and change { brand.reload.users_count }.by(-1)
        .and change(Setting, :count).by(-1)

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(brand.reload.users).not_to include(user)
    end

    it "does not destroy a user who belongs to another brand" do
      user = create(:user)
      brand = create(:brand)
      other_brand = create(:brand)
      create(:brand_user, brand: brand, user: user)
      create(:brand_user, brand: other_brand, user: user)

      expect do
        delete brand_user_path(brand, user)
      end.not_to change(User, :count)

      expect(response).to have_http_status(303)
      expect(response).to redirect_to(root_path(brand_id: brand.id))
      expect(user.reload.brands).not_to include(brand)
      expect(user.brands).to include(other_brand)
      expect(Setting.exists?(brand: other_brand, user: user)).to be(true)
    end
  end
end
