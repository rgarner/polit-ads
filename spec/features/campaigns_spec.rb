require 'rails_helper'

RSpec.describe 'Campaigns' do
  let(:trump) { create :campaign, :trump }
  let(:biden) { create :campaign, :biden }

  def given_both_campaigns_have_adverts
    create :advert, :trump, funded_by: trump.funding_entities.first
    create :advert, :biden, funded_by: biden.funding_entities.first

    CampaignDailySummary.refresh
  end

  scenario 'Showing both campaigns against one another' do
    given_both_campaigns_have_adverts

    visit '/campaigns'

    expect(page).to have_content('based on 2 adverts from the Biden and Trump campaigns')
  end

  scenario 'Showing in individual campaign' do
    given_both_campaigns_have_adverts

    # When I visit the campaign
    visit '/campaigns/trump'

    # Then I should see that campaign's summary with a graph
    expect(page).to have_content('Trump campaign wants')
    expect(page).to have_selector('div#chart-1')
  end
end
