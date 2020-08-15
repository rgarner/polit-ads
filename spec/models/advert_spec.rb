require 'rails_helper'

RSpec.describe Advert do
  describe '#trump_or_biden' do
    let!(:biden_ad) { create :advert, :biden }
    let!(:trump_ad) { create :advert, :trump }
    let!(:other_ad) { create :advert, :other }

    subject(:ads_of_interest) { Advert.trump_or_biden }

    it 'gets Trump ads and Biden ads' do
      aggregate_failures do
        expect(ads_of_interest).to include(biden_ad)
        expect(ads_of_interest).to include(trump_ad)
        expect(ads_of_interest).not_to include(other_ad)
      end
    end
  end
end
