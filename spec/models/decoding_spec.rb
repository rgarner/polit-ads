require 'rails_helper'

RSpec.describe Decoding do
  subject(:decoding) { Decoding.new(advert.id) }

  let(:trump)        { create :campaign, :trump }
  let(:biden)        { create :campaign, :biden }
  let(:funding_host) { create :host, :funding, campaign: trump }
  let(:action_host)  { create :host, :data, campaign: trump }
  let(:merch_host)   { create :host, :shop, campaign: trump }
  let(:event_host)   { create :host, :event, campaign: trump }
  let(:vote_host)    { create :host, :vote, campaign: trump }
  let(:attack_host)  { create :host, :attack, campaign: biden }

  context 'link is for a Trump ad that thinks you are a monthly donor in a battleground state' do
    let(:advert) do
      create :advert, :trump, external_url: link, host: funding_host
    end

    let(:link) do
      'https://secure.winred.com/tmagac/scotus-800/?utm_medium=ad&utm_source=dp_fb&utm_campaign='\
      '20200927_md_scotuspick_djt_tmagac_ocpmypur_cm_audience0814_creative09836_copy02381_geo240_b_18-65_nfig_all_na_lp0508_fb1_ha_static_1_1_na&utm_content=fun'
    end

    it 'wants money' do
      expect(decoding.wants).to eql('money')
    end

    it 'knows which campaign it is in' do
      expect(decoding.campaign).to eql(trump)
    end

    describe 'thinks' do
      subject(:thinks) { decoding.thinks }

      before do
        geo = create :ad_code, :trump_geo
        create :ad_code_value_description,
               ad_code: geo,
               value: 'geo240', value_name: 'a battleground state'
      end

      it 'is a list where every sentence can follow "they think"' do
        expect(thinks).to be_an(Enumerable)
      end

      it 'thinks you live in a battleground state' do
        expect(thinks).to include('you live in a battleground state')
      end

      it 'thinks you are a monthly donor' do
        expect(thinks).to include('you already donate monthly')
      end

      it 'thinks you are 18-65 years old' do
        expect(thinks).to include('you are 18-65 years old')
      end
    end
  end

  context 'link is for a Trump attack ad' do
    let(:advert) do
      create :advert, :trump, external_url: link, host: action_host,
                              illuminate_tags: { 'is_civil' => false }
    end

    let(:link) do
      'https://action.donaldjtrump.com/trump-vs-biden-poll-v3/?utm_medium=ad&utm_source=dp_fb&utm_campaign='\
      '20200818_nd_bvtsurveyupdate_djt_tmagac_ocpmypur_bh_audience0704_creative05087_copy01705_'\
      'us_b_18-65_nfig_all_na_lp0263_fb3_sa_static_1_1_na&utm_content=sur'
    end

    it 'wants data' do
      expect(decoding.wants).to eql('your personal data')
    end

    describe 'thinks' do
      subject(:thinks) { decoding.thinks }

      it 'thinks you have not donated before' do
        expect(thinks).to include('you have not donated before')
      end

      it 'thinks it can make you angry' do
        expect(thinks).to include('they can make you angry')
      end

      it 'thinks you have Facebook interests (bh)' do
        expect(thinks).to include('you are interested in their campaign because of your Facebook likes or interests')
      end
    end
  end

  context 'link is for Trump merch' do
    let(:advert) do
      create :advert, :trump, external_url: link, host: merch_host,
                              illuminate_tags: { 'is_civil' => false }
    end

    let(:link) do
      'https://shop.donaldjtrump.com/?utm_medium=ad&utm_source=dp_fb&utm_campaign='\
      '20200423_na_store_djt_tmagacmerch_ocpmypur_bh_audience0452_creative02625_copy00655_us_b_18-65_nf_all_na_lp0001_shop_conversion_static_1_1_na&utm_content=sto'
    end

    it 'wants you to buy' do
      expect(decoding.wants).to eql('you to buy merchandise')
    end
  end

  context 'link is an attack host' do
    let(:advert) do
      create :advert, :trump,
             external_url: link, host: attack_host,
             illuminate_tags: { 'is_civil' => false }
    end

    let(:link) do
      'https://www.barelytherebiden.com/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200619_na_jbb_djt_djtnonfund_ocpmye_cm_audience0455_creative01839_copy00429_geo080_b_18-34_nf_all_18-34_lp0109_acq_postengagement_video_16_9_030s&utm_content=per'
    end

    it 'wants you to be deterred from voting' do
      expect(decoding.wants).to eql('to deter you from voting')
    end
  end

  context 'link is an event host' do
    let(:advert) do
      create :advert, :trump,
             external_url: link, host: event_host,
             illuminate_tags: { 'is_civil' => false }
    end

    let(:link) do
      'https://events.donaldjtrump.com/events/president-donald-j-trump-delivers-remarks-at-make-america-great-again-event-in-duluth-mn-september-30/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200928_na_mnremarks_djt_djtnonfund_ocpmycr_cm_audience0146_creative04567_copy00850_fl_b_18-65_nf_all_na_lp0204_acq_conversion_static_16_9_na&utm_content=eve'
    end

    it 'wants you to attend an event' do
      expect(decoding.wants).to eql('you to attend an event')
    end
  end

  context 'link is a vote host' do
    let(:advert) do
      create :advert, :trump,
             external_url: link, host: vote_host,
             illuminate_tags: { 'is_civil' => false }
    end

    let(:link) do
      'https://vote.donaldjtrump.com/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200924_na_gotvelvmi_t4mi_djtnonfund_ocpmycr_dt_audience1342_creative04226_copy00746_mi_b_18-65_nf_all_na_lp0198_acq_leads_video_16_9_015s&utm_content=pol'
    end

    it 'wants you to vote' do
      expect(decoding.wants).to eql('you to vote')
    end
  end
end
