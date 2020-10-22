class Decoding::Trump < Decoding
  INDEX_DONOR_ACTION  = '1'.freeze
  INDEX_AUDIENCE_TYPE = '6'.freeze
  INDEX_LOCATION      = '10'.freeze
  INDEX_AGE           = '12'.freeze
  INDEX_AD_GOAL       = '17'.freeze

  def you_have_donated
    {
      'nd' => I18n.t('thinks.donor.you_have_not_donated_before'),
      'rd' => I18n.t('thinks.donor.you_have_donated_before'),
      'md' => I18n.t('thinks.donor.you_already_donate_monthly'),
    }[donor_action]
  end

  def you_live_here
    location_description = location(location_code)
    I18n.translate('thinks.you_live_here', location: location_description) if location_description
  end

  def you_are_an_audience_type
    case advert.utm_values&.fetch(INDEX_AUDIENCE_TYPE, nil)
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
    I18n.translate('thinks.you_are_this_old', age: age) if age.present?
  end

  def wants_key
    super
    case [@wants_key, ad_goal]
    in ['data', /per(s?)/]
      'to_persuade_you'
    else
      @wants_key
    end
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

  def location_code
    advert.utm_values&.fetch(INDEX_LOCATION, nil)
  end

  def donor_action
    advert.utm_values&.fetch(INDEX_DONOR_ACTION, nil)
  end

  def age
    advert.utm_values&.fetch(INDEX_AGE, nil)
  end

  def ad_goal
    advert.utm_values&.fetch(INDEX_AD_GOAL, nil)
  end
end
