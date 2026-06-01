FactoryBot.define do
  factory :setting do
    brand_user { build(:brand_user) }
    key { "notification_email" }
    value { "enabled" }
  end
end
