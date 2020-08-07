class AddHostPurpose < ActiveRecord::Migration[6.0]
  def change
    add_column :hosts, :purpose, :string
  end
end
