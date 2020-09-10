class AddAdCodeDescriptionConfidence < ActiveRecord::Migration[6.0]
  def change
    add_column :ad_codes, :description, :string
    add_column :ad_codes, :confidence, :string
  end
end
