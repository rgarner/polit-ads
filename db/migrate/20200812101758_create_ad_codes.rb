class CreateAdCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_codes do |t|
      t.string :slug
      t.string :name
      t.integer :index
      t.integer :quality
      t.references :campaign

      t.timestamps
    end

    add_index :ad_codes, %i[campaign_id index], unique: true
  end
end
