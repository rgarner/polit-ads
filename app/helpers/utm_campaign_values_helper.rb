module UtmCampaignValuesHelper
  def utm_indices_except(index)
    (0..22).to_a - [index]
  end

  def last_30_days_path(index)
    utm_campaign_value_between_path(
      utm_campaign_value_id: index,
      start: Date.today - 30.days,
      end: Date.today
    )
  end
end
