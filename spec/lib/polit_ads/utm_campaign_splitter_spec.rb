require 'rails_helper'
require 'polit_ads/utm_campaign_splitter'

RSpec.describe PolitAds::UtmCampaignSplitter do
  let!(:advert) { create :advert, :trump, external_url: external_url }

  let(:splitter) { PolitAds::UtmCampaignSplitter.new }

  before { splitter.populate }

  subject(:values) { advert.ad_code_value_usages.order(:index).map(&:value) }

  context 'the ad is entirely usual' do
    let(:external_url) do
      'https://action.donaldjtrump.com/trump-vs-biden-poll-v3/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200907_nr_bvtsurveyupdate_djt_tmagac_ocpmycr_bh_audience0240_creative05003_copy01582_geo240_b_18-65_nf_all_na_lp0263_fb5_sa_static_1_1_na&utm_content=sur'
    end

    it 'has all the values where you would expect them' do
      expect(values[0]).to eql('20200907')
      expect(values[1]).to eql('nr')
      expect(values[2]).to eql('bvtsurveyupdate')
      expect(values[3]).to eql('djt')
      expect(values[4]).to eql('tmagac')
      expect(values[5]).to eql('ocpmycr')
      expect(values[6]).to eql('bh')
      expect(values[7]).to eql('audience0240')
      expect(values[8]).to eql('creative05003')
      expect(values[9]).to eql('copy01582')
      expect(values[10]).to eql('geo240')
      expect(values[11]).to eql('b')
      expect(values[12]).to eql('18-65')
      expect(values[13]).to eql('nf')
      expect(values[14]).to eql('all')
      expect(values[15]).to eql('na')
      expect(values[16]).to eql('lp0263')
      expect(values[17]).to eql('fb5')
      expect(values[18]).to eql('sa')
      expect(values[19]).to eql('static')
      expect(values[20]).to eql('1')
      expect(values[21]).to eql('1')
      expect(values[22]).to eql('na')
    end
  end

  context 'an ad is a bit messed up' do
    let(:external_url) do
      'https://vote.donaldjtrump.com/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20201023_https%3A%2F%2Fvote.donaldjtrump.com%2F%3Fgotvelvme_djt_djtnonfund_ocpmyelv_cm_audience1621_creative06519_copy00757_me_b_18-65_nf_all_https%3A%2F%2Fvote.donaldjtrump.com%2F%3Flp0241_acq_leads_video_16_9_083s&utm_content=pol'
    end

    it 'expands the 21 values to 23' do
      expect(values.count).to eql(23)
    end

    it 'has the creation date at 0' do
      expect(values[0]).to eql('20201023')
    end

    it 'normalises the supporter segment to na' do
      expect(values[1]).to eql('na')
    end

    it 'takes its ad campaign from the URL in utm1' do
      expect(values[2]).to eql('gotvelvme')
    end

    it 'puts everything up to utm16 in its right place' do
      expect(values[3]).to eql('djt')
      expect(values[4]).to eql('djtnonfund')
      expect(values[5]).to eql('ocpmyelv')
      expect(values[6]).to eql('cm')
      expect(values[7]).to eql('audience1621')
      expect(values[8]).to eql('creative06519')
      expect(values[9]).to eql('copy00757')
      expect(values[10]).to eql('me')
      expect(values[11]).to eql('b')
      expect(values[12]).to eql('18-65')
      expect(values[13]).to eql('nf')
      expect(values[14]).to eql('all')
    end

    it 'normalises the unused age range to na' do
      expect(values[15]).to eql('na')
    end

    it 'takes the utm16 ad lp code from the messed-up URL' do
      expect(values[16]).to eql('lp0241')
    end

    it 'remaps utm17-utm22 to the right values' do
      expect(values[17]).to eql('acq')   # Goal of the ad
      expect(values[18]).to eql('leads') # Facebook optimisation goal
      expect(values[19]).to eql('video') # Asset type
      expect(values[20]).to eql('16')    # Asset width
      expect(values[21]).to eql('9')     # Asset height
      expect(values[22]).to eql('083s')  # Video length
    end
  end
end
