FactoryBot.define do
  factory :setting do
    association :brand
    association :user
    key { "notification_email" }
    value { "enabled" }
  end
end
