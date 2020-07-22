class CreateUtmCampaignValues < ActiveRecord::Migration[6.0]
  def change
    create_table :utm_campaign_values do |t|
      t.belongs_to :advert

      t.integer :index, null: false
      t.string :value, null: false

      t.index [:advert_id, :index, :value], unique: true
    end
  end
end
