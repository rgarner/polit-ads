class AddUtmValuesColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :utm_values, :jsonb
    add_index  :adverts, :utm_values, using: :gin
  end
end
