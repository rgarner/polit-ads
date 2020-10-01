class DecodingsController < ApplicationController
  def create
    advert = Advert.find_by_c14n_external_url(params[:link])
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
end
