class IndexTextSearch < ActiveRecord::Migration[6.0]
  def change
    add_index :adverts, :text_search, using: :gin, where: 'host_id IS NOT NULL'
  end
end
