##
# A noun: a decoding of a link.
#
#   Decomposes into a primary #wants and lots of #thinks
class Decoding
  attr_reader :advert

  def initialize(id)
    @advert = Advert.find(id)
  end

  def host
    advert.host
  end

  def campaign
    advert.host.campaign
  end

  def wants_key
    {
      'funding' => 'money',
      'data' => 'data',
      'shop' => 'you_to_buy',
      'vote' => 'you_to_vote',
      'attack' => 'you_to_be_deterred',
      'event' => 'you_to_attend'
    }[host.purpose]
  end

  def wants
    return nil if wants_key.nil?

    I18n.t("wants.#{wants_key}")
  end

  def thinks
    [
      you_live_here,
      you_have_donated,
      you_are_this_old,
      they_can_make_you_angry,
      you_are_an_audience_type
    ].compact
  end

  private

  def you_are_this_old
    I18n.translate('thinks.you_are_this_old', age: advert.utm_values['12'])
  end

  def you_have_donated
    {
      'nd' => I18n.t('thinks.donor.you_have_not_donated_before'),
      'rd' => I18n.t('thinks.donor.you_have_donated_before'),
      'md' => I18n.t('thinks.donor.you_already_donate_monthly'),
    }[advert.utm_values['1']]
  end

  def you_live_here
    location_description = location(advert.utm_values['10'])
    I18n.translate('thinks.you_live_here', location: location_description) if location_description
  end

  def you_are_an_audience_type
    case advert.utm_values['6']
    when 'bh' then I18n.t('thinks.audience_type.has_interests')
    when 'cm' then I18n.t('thinks.audience_type.custom_audience')
    end
  end

  def they_can_make_you_angry
    return nil unless advert.illuminate_tags.present?

    I18n.translate('thinks.they_can_make_you_angry') if advert.uncivil?
  end

  def url
    @url = Addressable::URI.parse(@link)
  end

  def utm_campaign_values
    url.query_values['utm_campaign'].split('_')
  end

  def location(location)
    case location
    when 'us' then nil
    else
      AdCodeValueDescription
        .joins(:ad_code)
        .find_by('ad_codes.index = 10 AND value = ?', location)&.value_name
    end
  end
end
