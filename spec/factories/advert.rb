FactoryBot.define do
  sequence(:id)      { |n| "123456#{n}" }
  sequence(:page_id) { |n| "12345678#{n}" }
  sequence(:post_id) { |n| "1234567890#{n}" }

  factory :advert do
    id
    page_id
    post_id
    host

    ad_creation_time       { 2.days.ago }
    ad_delivery_start_time { 2.days.ago }

    country { 'US' }

    transient do
      ad_codes { {} }
    end

    after(:create) do |advert, evaluator|
      evaluator.ad_codes.each_pair do |index, value|
        advert.ad_code_value_usages << AdCodeValueUsage.new(index: index, value: value)
      end
      advert.ad_library_url = "https://www.facebook.com/ads/library/?id=#{advert.post_id}"
      advert.save!
    end

    trait :biden do
      page_name       { 'Joe Biden' }
      funding_entity  { 'BIDEN VICTORY FUND' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=1610017795840485&access_token=foobar' }

      before(:create) do |advert|
        if advert.external_url && advert.utm_values.nil?
          uri = Addressable::URI.parse(advert.external_url)

          utm_values = uri.query_values&.[]('source')&.split(/[_|]/)

          if utm_values
            advert.utm_values = {}
            utm_values.each_with_index { |value, index| advert.utm_values[index.to_s] = value }
          end
          advert.save!
        end
      end
    end

    trait :trump do
      page_name       { 'Donald J. Trump' }
      funding_entity  { 'DONALD J. TRUMP FOR PRESIDENT, INC.' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=2640868079488103&access_token=foobar' }

      after(:create) do |advert|
        if advert.external_url && advert.utm_values.nil?
          uri = Addressable::URI.parse(advert.external_url)
          utm_values = uri.query_values['utm_campaign']&.split('_')

          if utm_values # Apps utm_values are nil
            advert.utm_values = {}
            utm_values.each_with_index { |value, index| advert.utm_values[index.to_s] = value }
          end
          advert.save!
        end
      end
    end

    trait :other do
      country         { 'GB' }
      page_name       { 'Amnesty International UK' }
      funding_entity  { 'Amnesty International UK' }
      ad_snapshot_url { 'https://www.facebook.com/ads/archive/render_ad/?id=2575089119400121&access_token=foobar' }
    end

    trait :new do
      ad_creation_time { 1.day.ago }
    end

    trait :old do
      ad_creation_time { 30.days.ago }
    end
  end
end
