class Decoding::Trump < Decoding
  INDEX_DONOR_STATUS  = '1'.freeze
  INDEX_AUDIENCE_TYPE = '6'.freeze
  INDEX_LOCATION      = '10'.freeze
  INDEX_AGE           = '12'.freeze

  def you_have_donated
    {
      'nd' => I18n.t('thinks.donor.you_have_not_donated_before'),
      'rd' => I18n.t('thinks.donor.you_have_donated_before'),
      'md' => I18n.t('thinks.donor.you_already_donate_monthly'),
    }[advert.utm_values[INDEX_DONOR_STATUS]]
  end

  def you_live_here
    location_description = location(advert.utm_values[INDEX_LOCATION])
    I18n.translate('thinks.you_live_here', location: location_description) if location_description
  end

  def you_are_an_audience_type
    case advert.utm_values[INDEX_AUDIENCE_TYPE]
    when 'bh' then I18n.t('thinks.audience_type.has_interests')
    when 'cm' then I18n.t('thinks.audience_type.custom_audience')
    end
  end

  def location(location)
    case location
    when 'us' then nil
    else
      AdCodeValueDescription
        .joins(:ad_code)
        .find_by('ad_codes.index = ? AND value = ?', INDEX_LOCATION, location)&.value_name
    end
  end

  def you_are_this_old
    I18n.translate('thinks.you_are_this_old', age: advert.utm_values[INDEX_AGE])
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
end
