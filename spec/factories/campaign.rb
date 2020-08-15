FactoryBot.define do
  factory :campaign do
    trait :trump do
      name { 'Donald J. Trump' }
      slug { 'trump' }

      funding_entities { [create(:funding_entity, name: 'TRUMP MAKE AMERICA GREAT AGAIN COMMITTEE')] }
    end

    trait :biden do
      name { 'Joe Biden' }
      slug { 'biden' }

      funding_entities { [create(:funding_entity, name: 'BIDEN FOR PRESIDENT')] }
    end
  end
end
