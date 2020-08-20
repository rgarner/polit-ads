require 'rails_helper'

RSpec.describe '/campaigns' do
  let(:trump) { create :campaign, :trump }
  let(:biden) { create :campaign, :biden }

  def given_both_campaigns_have_adverts
    create :advert, :trump, funded_by: trump.funding_entities.first
    create :advert, :biden, funded_by: biden.funding_entities.first
  end

  scenario 'both campaigns have adverts' do
    given_both_campaigns_have_adverts

    visit '/campaigns'

    expect(page).to have_content("based on 2 adverts from the Biden and Trump campaigns")
  end
end
