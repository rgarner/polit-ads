class AddExternalUrls < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :external_tracking_url, :string
    add_column :adverts, :external_url, :string
    add_column :adverts, :external_text, :string
  end
end
