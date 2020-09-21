require 'rails_helper'
require 'polit_ads/biden_source_splitter'

RSpec.describe PolitAds::BidenSourceSplitter do
  let!(:advert) { create :advert, :biden, external_url: external_url }

  let(:splitter) { PolitAds::BidenSourceSplitter.new }

  before { splitter.populate }

  context 'an ad has 14 values' do
    let(:external_url) do
      'https://go.biden.com/?source=omvf_fb_20200716teamjoe_EA_014leftM_FB_US_18-65_MF_a002_Graphic2Copy1_STA_SU_SQ'
    end

    it 'puts those values in ad_code_values' do
      expect(AdCodeValueUsage.count).to eql(14)
      expect(advert.ad_code_value_usages.count).to eql(14)
    end

    it 'normalises index 3 by downcasing' do
      expect(advert.ad_code_value_usages.find_by!(index: 3).value).to eql('ea')
    end
  end

  context 'an ad has 5 values' do
    let(:external_url) do
      'https://go.biden.com/?source=om_fb_vpfirsttoknow_acq_view10'
    end

    it 'keeps the first 5 values' do
      expect(advert.ad_code_value_usages.find_by!(index: 0).value).to eql('om')
      expect(advert.ad_code_value_usages.find_by!(index: 1).value).to eql('fb')
      expect(advert.ad_code_value_usages.find_by!(index: 2).value).to eql('vpfirsttoknow')
      expect(advert.ad_code_value_usages.find_by!(index: 3).value).to eql('acq')
      expect(advert.ad_code_value_usages.find_by!(index: 4).value).to eql('view10')
    end

    it 'sets the rest <empty>' do
      (5..13).each { |n| expect(advert.ad_code_value_usages.find_by!(index: n).value).to eql('<empty>') }
    end
  end

  context 'an ad has 6 values' do
    let(:external_url) do
      'https://go.biden.com/?source=omvf_fb_20200812getinvolved_ea_000_a002'
    end

    it 'keeps the first 5 values' do
      expect(advert.ad_code_value_usages.find_by!(index: 0).value).to eql('omvf')
      expect(advert.ad_code_value_usages.find_by!(index: 1).value).to eql('fb')
      expect(advert.ad_code_value_usages.find_by!(index: 2).value).to eql('20200812getinvolved')
      expect(advert.ad_code_value_usages.find_by!(index: 3).value).to eql('ea')
      expect(advert.ad_code_value_usages.find_by!(index: 4).value).to eql('000')
    end

    it 'maps the last audience param to bid9, leaving bid5 empty' do
      aggregate_failures do
        expect(advert.ad_code_value_usages.find_by!(index: 9).value).to eql('a002')
        expect(advert.ad_code_value_usages.find_by!(index: 5).value).to eql('<empty>')
      end
    end

    it 'makes everything else <empty>' do
      (5..8).each { |n| expect(advert.ad_code_value_usages.find_by!(index: n).value).to eql('<empty>') }
      (10..13).each { |n| expect(advert.ad_code_value_usages.find_by!(index: n).value).to eql('<empty>') }
    end
  end
end
