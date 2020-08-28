class CreateAdCodeValueDescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_code_value_descriptions do |t|
      t.string :value
      t.string :value_name
      t.string :confidence
      t.string :description
      t.references :ad_code, foreign_key: true

      t.date :published
    end
  end
end
