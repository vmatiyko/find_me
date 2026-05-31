# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:brand_users).dependent(:destroy) }
    it { is_expected.to have_many(:brands).through(:brand_users) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "normalization" do
    it "normalizes first name, last name, and email before validation" do
      user = build(
        :user,
        first_name: " Test Jo hn ",
        last_name: " Doe Test ",
        email: " Person@TestExample.COM "
      )

      user.validate

      expect(user.first_name).to eq("john")
      expect(user.last_name).to eq("doe")
      expect(user.email).to eq("person@example.com")
    end

    it "rejects fields that normalize to blank" do
      user = build(:user, first_name: "test", last_name: "test", email: "test")

      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
      expect(user.errors[:last_name]).to include("can't be blank")
      expect(user.errors[:email]).to include("can't be blank")
    end
  end
end
