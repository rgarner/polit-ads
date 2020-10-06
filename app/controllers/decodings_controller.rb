##
# Create a /decodings/:id resource
class DecodingsController < ApplicationController
  POST_ID        = /[0-9]{15,25}/.freeze
  AD_LIBRARY_URL = %r{^https://www.facebook.com/ads/library/\?id=(?<post_id>[0-9]{15,25})}.freeze

  def create
    advert = find_advert

    if advert
      redirect_to decoding_path(advert)
    else
      flash[:danger] = 'We’re sorry, this isn’t an advert we know about. Please try again.'
      redirect_to adverts_decode_a_link_path
    end
  end

  def show
    @decoding = Decoding.create(params[:id])
    render :show
  end

  private

  def find_advert
    case params[:link].strip
    when AD_LIBRARY_URL
      Advert.find_by(post_id: $LAST_MATCH_INFO[:post_id])
    when POST_ID
      Advert.find_by(post_id: params[:link])
    else
      Advert.find_by_c14n_external_url(params[:link])
    end
  end
end
