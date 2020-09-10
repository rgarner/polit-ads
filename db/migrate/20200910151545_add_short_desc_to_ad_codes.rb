class AddShortDescToAdCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_codes, :short_desc, :string
  end
end
