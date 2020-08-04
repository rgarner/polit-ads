module UtmCampaignValuesHelper
  def utm_indices_except(index)
    (0..22).to_a - [index]
  end
end