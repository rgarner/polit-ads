class CreateHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :hosts do |t|
      t.string :hostname
    end

    add_column :adverts, :host_id, :integer

    add_index :hosts, :hostname, unique: true
    add_index :adverts, :host_id
  end
end
