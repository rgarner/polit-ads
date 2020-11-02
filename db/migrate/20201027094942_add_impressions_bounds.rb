class AddImpressionsBounds < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :impressions_lower_bound, :integer
    add_column :adverts, :impressions_upper_bound, :integer
  end
end
