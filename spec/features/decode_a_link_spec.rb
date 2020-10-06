require 'rails_helper'

RSpec.describe '/adverts/decode-a-link' do
  def given_an_advert_exists
    campaign = create :campaign, :trump
    host = create :host, :data, campaign: campaign
    @advert = create :advert, :trump, host: host, external_url:
      'https://action.donaldjtrump.com/trump-vs-biden-poll-v3/?utm_medium=ad&utm_source=dp_fb&utm_campaign='\
      '20200818_nd_bvtsurveyupdate_djt_tmagac_ocpmypur_bh_audience0704_creative05087_copy01705_us_b_18-65_nfig_all_na_lp0263_fb3_sa_static_1_1_na&utm_content=sur',
      illuminate_tags: { 'is_message_type_attack' => true, 'is_civil' => false }
  end

  scenario 'no advert exists' do
    # Given no matching advert exists

    # When I supply a link for analysis
    visit '/adverts/decode-a-link'
    fill_in 'Paste a link', with: 'http://example.com/non-existent'
    click_button 'Go'

    # Then I should see that no advert could be found
    expect(page).to have_content('We’re sorry, this isn’t an advert we know about. Please try again.')

    # And I should see the 'paste a link' field again
    expect(page).to have_content('Paste a link')
  end

  scenario 'a matching advert exists' do
    given_an_advert_exists

    # When I supply a link for analysis
    visit '/adverts/decode-a-link'
    fill_in 'Paste a link', with: @advert.external_url + '&fbclid=IwAR2H1jTbXedvDs5YOo5TxylDGN_ndGYoZERkQnkVNj7NALZmVeTaVGnu7Qo'
    click_button 'Go'

    # Then I should see an indicator of what the campaign wants from me
    expect(page).to have_content('The Trump campaign wants to persuade you')

    # And I should see what the campaign thinks it knows about me
    expect(page).to have_content('They think:')
    expect(page).to have_content('you have not donated before')
    expect(page).to have_content('you are 18-65 years old')
    expect(page).to have_content('you are interested in their campaign because of your Facebook likes or interests')
  end
end
