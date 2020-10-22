class Decoding::Biden < Decoding
  INDEX_AD_GOAL = '3'.freeze
  INDEX_AGE = '7'.freeze

  def wants_key
    @wants_key = super

    if %w[data to_persuade_you].include?(@wants_key) && ad_goal == 'vol'
      'you_to_volunteer'
    else
      @wants_key
    end
  end

  def you_are_this_old
    age = advert.utm_values&.fetch(INDEX_AGE, nil)
    I18n.translate('thinks.you_are_this_old', age: age) if age && age != '<empty>'
  end

  def you_are_not_a_supporter
    I18n.t('thinks.you_are_not_a_supporter') if ad_goal == 'acq'
  end

  def thinks
    [
      they_can_make_you_angry,
      you_are_this_old,
      you_are_not_a_supporter
    ].compact
  end

  private

  def ad_goal
    advert.utm_values&.fetch(INDEX_AD_GOAL, nil)
  end
end
