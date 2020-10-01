class AddWantsKeyToAdverts < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :wants_key, :string
  end
end
