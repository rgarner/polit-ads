require 'rails_helper'

RSpec.describe 'Looking at ad codes' do
  let(:trump)      { create :campaign, :trump }
  let(:trump_host) { create :host, campaign: trump }
  let(:biden)      { create :campaign, :biden }
  let(:biden_host) { create :host, campaign: biden }

  def given_old_and_new_ad_codes_exist
    create :ad_code, index: 3, name: 'trump-code', campaign: trump
    create :ad_code, index: 3, name: 'biden-code', campaign: biden
    create :advert, :trump, :old, funded_by: trump.funding_entities.first, host: trump_host, ad_codes: { 3 => 'bv4t' }
    create :advert, :trump, :new, funded_by: trump.funding_entities.first, host: trump_host, ad_codes: { 3 => 'bv4t' }
    create :advert, :trump, :new, funded_by: trump.funding_entities.first, host: trump_host, ad_codes: { 3 => 'trump-val' }
    create :advert, :biden, funded_by: biden.funding_entities.first, host: biden_host, ad_codes: { 3 => 'biden-val' }

    AdCodeValueSummary.refresh
  end

  scenario 'both campaigns have adverts' do
    given_old_and_new_ad_codes_exist

    # When I visit a campaign's ad codes
    visit '/campaigns/trump/ad_codes'

    # I should see only that campaign's ad codes
    expect(page).to have_content('bv4t')
    expect(page).to have_content('50.0% of adverts')

    # Put back when Ad code values are campaign-aware
    ## expect(page).not_to have_content('biden-val')
  end

  scenario 'viewing an ad code timeline by range' do
    # Given an ad_code exists
    create :ad_code, index: 3, name: 'trump-code', campaign: trump

    # When I visit the ad_code page
    visit '/campaigns/trump/ad_codes/3/timeline'

    # Then I should land on the 30 days timeline
    expect(page).to have_link('Last 30 Days', class: 'active')

    # And I click the "last 7 days link"
    click_link 'Last 7 Days'

    # Then I should be on the last 7 days page
    expect(page).to have_link('Last 7 Days', class: 'active')
  end
end
