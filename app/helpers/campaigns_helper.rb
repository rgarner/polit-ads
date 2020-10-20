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
      'approximate_spend' => 'Spend',
      'percentage' => '% of count'
    }[params[:dimension]&.downcase] || 'Count'
  end

  CAMPAIGN_RANGES = %w[
    daily
    weekly
    monthly
  ].freeze

  def campaign_range_links
    tag.ul class: 'nav nav-pills' do
      CAMPAIGN_RANGES.map do |label|
        active = params[:range] == label.to_s || params[:range].nil? && label == 'weekly'
        tag.li class: 'nav-item' do
          link_to label.to_s.titleize,
            request.query_parameters.merge(range: label),
            class: "nav-link #{'active' if active }"
        end
      end.join.html_safe
    end
  end
end
