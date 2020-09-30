module CampaignsHelper
  def advert_count_text
    "#{number_with_delimiter(@campaigns.map(&:ad_count).reduce(&:+))} adverts"
  end

  def campaign_face(slug, options = {})
    image_tag(
      asset_path("face-circle-#{slug}-700x700.png"),
      class: "face img-fluid #{slug} " + options[:class].to_s
    )
  end

  def dimension_label
    {
      'count' => 'Count',
      'approximate_spend' => 'Spend'
    }[params[:dimension]&.downcase] || 'Count'
  end
end
