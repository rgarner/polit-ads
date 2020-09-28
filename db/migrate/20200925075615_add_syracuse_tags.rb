class AddSyracuseTags < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :illuminate_tags, :jsonb
    add_index :adverts, :post_id
  end
end
