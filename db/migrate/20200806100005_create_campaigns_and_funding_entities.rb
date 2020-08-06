class CreateCampaignsAndFundingEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :slug

      t.timestamps

      t.index :slug, unique: true
    end

    create_table :funding_entities do |t|
      t.string :name
      t.belongs_to :campaign

      t.timestamps

      t.index :name, unique: true
    end

    change_table :adverts do |t|
      t.references :funding_entity
    end
  end
end
