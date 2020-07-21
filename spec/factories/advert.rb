FactoryBot.define do
  sequence(:id)      { |n| "123456#{n}" }
  sequence(:page_id) { |n| "12345678#{n}" }
  sequence(:post_id) { |n| "1234567890#{n}" }

  factory :advert do
    id
    page_id
    post_id

    country { 'US' }

    trait :biden do
      page_name       { 'Joe Biden' }
      funding_entity  { 'BIDEN VICTORY FUND' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=1610017795840485&access_token=foobar' }
    end

    trait :trump do
      page_name       { 'Donald J. Trump' }
      funding_entity  { 'DONALD J. TRUMP FOR PRESIDENT, INC.' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=2640868079488103&access_token=foobar' }
    end

    trait :other do
      country         { 'GB' }
      page_name       { 'Amnesty International UK' }
      funding_entity  { 'Amnesty International UK' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=2575089119400121&access_token=foobar' }
    end
  end
end