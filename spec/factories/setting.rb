FactoryBot.define do
  factory :setting do
    association :brand
    key { "notification_email" }
    value { "enabled" }
  end
end
