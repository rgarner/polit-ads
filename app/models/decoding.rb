##
# A noun: a decoding of a link.
#
#   Decomposes into a primary #wants and lots of #thinks
class Decoding
  attr_reader :advert

  HOST_PURPOSE_TO_WANTS_KEY = {
    'funding' => 'money',
    'data' => 'data',
    'shop' => 'you_to_buy',
    'vote' => 'you_to_vote',
    'attack' => 'you_to_be_deterred',
    'event' => 'you_to_attend',
    'app' => 'you_to_install_an_app'
  }.freeze

  def self.create(ad_or_id)
    advert = ad_or_id.is_a?(Advert) ? ad_or_id : Advert.find_by!(post_id: ad_or_id)
    klass = if advert.host.campaign.present?
              const_get("Decoding::#{advert.host.campaign.slug.capitalize}")
            elsif advert.host.present?
              Decoding
            else
              raise 'Advert does not have a host. Decoding.create is only for ads with hosts.'
            end
    klass.new(advert)
  end

  def initialize(advert)
    @advert = advert
  end

  def host
    advert.host
  end

  def campaign
    advert.host.campaign
  end

  def wants_key
    @wants_key ||= HOST_PURPOSE_TO_WANTS_KEY[host.purpose]
  end

  def wants
    return nil if wants_key.nil?

    I18n.t("wants.#{wants_key}")
  end

  protected

  def they_can_make_you_angry
    return nil unless advert.illuminate_tags.present?

    I18n.translate('thinks.they_can_make_you_angry') if advert.uncivil?
  end

  def url
    @url = Addressable::URI.parse(@link)
  end
end
