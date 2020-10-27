require 'rails_helper'

RSpec.describe Decoding do
  subject(:decoding) { Decoding.create(advert.fb_ad_id) }

  let(:trump)        { create :campaign, :trump }
  let(:biden)        { create :campaign, :biden }

  let(:funding_host)   { create :host, :funding, campaign: trump }
  let(:action_host)    { create :host, :data, campaign: trump }
  let(:merch_host)     { create :host, :shop, campaign: trump }
  let(:event_host)     { create :host, :event, campaign: trump }
  let(:vote_host)      { create :host, :vote, campaign: trump }
  let(:attack_host)    { create :host, :attack, campaign: biden }
  let(:app_host)       { create :host, :app, campaign: nil }
  let(:volunteer_host) { create :host, :volunteer, campaign: biden }

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

  context 'link is for a Trump app' do
    let(:advert) { create :advert, :trump, funded_by: trump.funding_entities.first, external_url: link, host: app_host }
    let(:link) { 'http://play.google.com/store/apps/details?id=com.ucampaignapp.americafirst' }

    it 'wants you to install' do
      expect(decoding.wants).to eql('you to install their app')
    end

    it 'thinks' do
      expect(decoding.thinks).to eql([])
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
      create :advert, :trump, external_url: link, host: vote_host
    end

    let(:link) do
      'https://vote.donaldjtrump.com/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200924_na_gotvelvmi_t4mi_djtnonfund_ocpmycr_dt_audience1342_creative04226_copy00746_mi_b_18-65_nf_all_na_lp0198_acq_leads_video_16_9_015s&utm_content=pol'
    end

    it 'wants you to vote' do
      expect(decoding.wants).to eql('you to vote')
    end
  end

  context 'link is a data host but you are persuadable' do
    let(:advert) do
      create :advert, :trump, external_url: link, host: action_host
    end

    let(:link) do
      'https://forms.donaldjtrump.com/landing/biden-progressive/?utm_medium=ad&utm_source=dp_fb&utm_campaign=20200928_na_resn_djt_djtnonfund_ocpmye_cm_audience1353_creative04558_copy00857_wi_b_18-65_nfig_all_na_lp0173_pers_aware_video_16_9_015s&utm_content=pol'
    end

    it 'wants to persuade you' do
      expect(decoding.wants).to eql('to persuade you')
    end
  end

  context 'link is a Biden volunteer ad' do
    let(:advert) do
      create :advert,
             :biden, external_url: link, host: create(:host, :go_joe_biden, campaign: biden),
                     illuminate_tags: { 'is_civil': true, 'is_message_type_advocacy' => true }
    end

    let(:link) do
      'https://go.joebiden.com/page/s/vol-hb-september-california/?source=om_fb_20200906getinvolved_vol_000_a001_&refcode=om_fb_20200906getinvolved_VOL_000_a001_&utm_medium=om'
    end

    it 'wants you to volunteer' do
      expect(decoding.wants).to eql('you to volunteer')
    end

    it 'has insufficient info for #thinks' do
      expect(decoding.thinks).to be_empty
    end
  end

  context 'link is a Biden volunteer host' do
    let(:advert) do
      create :advert,
             :biden, external_url: link, host: volunteer_host,
             illuminate_tags: nil
    end

    let(:link) do
      'https://www.mobilize.us/joebiden/event/324568/?utm_source=om&utm_medium=fb'
    end

    it 'wants you to volunteer' do
      expect(decoding.wants).to eql('you to volunteer')
    end

    it 'has insufficient info for #thinks' do
      expect(decoding.thinks).to be_empty
    end
  end

  context 'link is a Biden donation ad' do
    let(:advert) do
      create :advert,
             :biden, external_url: link, host: create(:host, :biden_funding, campaign: biden)
    end

    let(:link) do
      'https://secure.actblue.com/donate/ads_dd_fb_launch_july2020?source=omvf_fb_20200719averagegifts_DD_013emlal5%7CFB%7CUS%7C18-34%7CMF_a003%7CAverageGifts%7CSTA%7CDN10%7CREC&refcode=omvf_fb_20200719averagegifts_DD_013emlal5%7CFB%7CUS%7C18-34%7CMF_a003%7CAverageGifts%7CSTA%7CDN10%7CREC&utm_medium=omvf&utm_source=fb&utm_campaign=averagegifts&utm_content=DD'
    end

    it 'wants money' do
      expect(decoding.wants).to eql('money')
    end

    it 'thinks you are 18-34' do
      expect(decoding.thinks).to include('you are 18-34 years old')
    end
  end

  context 'link is a Biden new supporter acq ad' do
    let(:advert) do
      create :advert,
             :biden, external_url: link, host: create(:host, :go_joe_biden, campaign: biden)
    end

    let(:link) do
      'https://go.joebiden.com/page/s/BVF-endorse-joe-a?source=omvf_fb_july20sudtc_acq_pla1-10&subsource=omvf'
    end

    it 'wants data' do
      expect(decoding.wants).to eql('your personal data')
    end

    it 'thinks you are not currently a supporter' do
      expect(decoding.thinks).to include('you are not yet an active supporter')
    end
  end

  context 'link is a Biden persuasion ad' do
    let(:advert) do
      create :advert,
             :biden,
             external_url: link, host: create(:host, :go_joe_biden, campaign: biden),
             illuminate_tags: { 'is_message_type_advocacy': true, 'is_civil': true }
    end

    let(:link) do
      'https://go.joebiden.com/page/sp/bfp-story-collection?source=om_fb_2008storycollection_6bgst&subsource=om'
    end

    it 'wants to persuade you' do
      expect(decoding.wants).to eql('to persuade you')
    end
  end

  context 'link is a Biden news ad' do
    let(:advert) do
      create :advert,
             :biden,
             external_url: link, host: create(:host, hostname: 'www.fox6now.com', purpose: 'news', campaign: biden),
             illuminate_tags: {}
    end

    let(:link) do
      'https://www.fox6now.com/news/joe-biden-campaigns-in-manitowoc-promises-to-buy-american'
    end

    it 'wants to persuade you' do
      expect(decoding.wants).to eql('to persuade you')
    end
  end

  context 'link has empty age' do
    let(:advert) do
      # We can't let the factory do it for us as it's only simulating production,
      # so hard-code some <empty> values
      create :advert,
             :biden,
             external_url: link, host: create(:host, :go_joe_biden, campaign: biden),
             utm_values: {"0": 'omvf', "1": 'fb', "2": '20200925trumpsscotuspick', "3": 'ea', "4": '000', "5": '<empty>', "6": '<empty>', "7": '<empty>', "8": '<empty>', "9": 'a004', "10": '<empty>', "11": '<empty>', "12": '<empty>', "13": '<empty>'}
    end

    let(:link) do
      'https://go.joebiden.com/page/s/bvf2020-supreme-court-pick-petition-fb-sept2020/?source=omvf_fb_20200925trumpsscotuspick_ea_000_a004_&refcode=omvf_fb_20200925trumpsscotuspick_EA_000_a004_&utm_medium=omvf'
    end

    it 'does not know how old you are' do
      expect(decoding.thinks).to be_empty
    end
  end
end
