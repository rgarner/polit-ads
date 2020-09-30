class AddExternalUrlIndexToAdverts < ActiveRecord::Migration[6.0]
  def change
    add_index :adverts, :external_url, using: :hash
  end
end
