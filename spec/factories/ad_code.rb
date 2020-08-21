FactoryBot.define do
  factory :ad_code do
    campaign

    quality { 5 }

    sequence(:index)

    name { "ad-code-#{index}" }
  end
end
