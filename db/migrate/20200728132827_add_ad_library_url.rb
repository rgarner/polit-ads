class AddAdLibraryUrl < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :ad_library_url, :string
  end
end
