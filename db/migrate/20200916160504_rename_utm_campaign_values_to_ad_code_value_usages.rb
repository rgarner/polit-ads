class RenameUtmCampaignValuesToAdCodeValueUsages < ActiveRecord::Migration[6.0]
  def change
    rename_table :utm_campaign_values, :ad_code_value_usages
  end
end
