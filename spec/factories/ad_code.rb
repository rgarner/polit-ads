FactoryBot.define do
  factory :ad_code do
    campaign

    quality { 5 }

    sequence(:index)

    name { "ad-code-#{index}" }

    trait :trump_geo do
      index { 10 }
    end
  end
end
