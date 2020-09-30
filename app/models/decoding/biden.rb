class Decoding::Biden < Decoding
  INDEX_AD_GOAL = '3'.freeze
  INDEX_AGE = '7'.freeze

  def wants_key
    @wants_key = super

    if @wants_key == 'data' && advert.utm_values[INDEX_AD_GOAL] == 'vol'
      'you_to_volunteer'
    else
      @wants_key
    end
  end

  def you_are_this_old
    age = advert.utm_values[INDEX_AGE]
    I18n.translate('thinks.you_are_this_old', age: age) if age
  end

  def thinks
    [
      they_can_make_you_angry,
      you_are_this_old
    ].compact
  end
end
