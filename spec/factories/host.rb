FactoryBot.define do
  factory :host do
    campaign

    sequence(:hostname) { |n| "host-#{n}.example.com" }

    trait :funding do
      purpose  { 'funding' }
      hostname { 'secure.winred.com' }
    end
    trait :data do
      purpose  { 'data' }
      hostname { 'action.donaldjtrump.com' }
    end
    trait :shop do
      purpose  { 'shop' }
      hostname { 'shop.donaldjtrump.com'}
    end
    trait :vote do
      purpose  { 'vote' }
      hostname { 'vote.donaldjtrump.com'}
    end
    trait :attack do
      purpose  { 'attack' }
      hostname { 'www.barelytherebiden.com'}
    end
    trait :event do
      purpose  { 'event' }
      hostname { 'events.donaldjtrump.com'}
    end
  end
end
