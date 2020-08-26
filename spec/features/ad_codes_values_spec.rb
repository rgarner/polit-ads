require 'rails_helper'

RSpec.describe 'Looking at ad code values' do
  let(:trump)      { create :campaign, :trump }
  let(:trump_host) { create :host, campaign: trump }

  def given_ad_code_values_exist
    create :ad_code, index: 3, name: 'bv4t', campaign: trump

    create :advert, :trump, funded_by: trump.funding_entities.first, host: trump_host, ad_codes: { 3 => 'bv4t' }
    create :advert, :trump, funded_by: trump.funding_entities.first, host: trump_host, ad_codes: { 3 => 'bv4t' }

    AdCodeValueSummary.refresh
  end

  scenario 'the value has some explanatory text', clean_database_with: :truncation do
    given_ad_code_values_exist

    # When I visit a campaign's ad code value
    visit '/campaigns/trump/ad_codes/3/values/bv4t'

    # I should see that campaign's ad code value
    expect(page).to have_content('bv4t')
    expect(page).to have_content('2 adverts')
  end
end
