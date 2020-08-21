FactoryBot.define do
  factory :host do
    campaign

    sequence(:hostname) { |n| "host-#{n}.example.com" }
  end
end
