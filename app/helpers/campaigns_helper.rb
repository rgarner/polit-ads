module CampaignsHelper
  def advert_count_text
    "#{number_with_delimiter(@campaigns.map(&:ad_count).reduce(&:+))} adverts"
  end

  def campaign_face(slug)
    image_tag(
      asset_path("face-circle-#{slug}-700x700.png"),
      class: 'face img-fluid'
    )
  end
end
