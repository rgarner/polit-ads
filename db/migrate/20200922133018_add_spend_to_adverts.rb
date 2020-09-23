class AddSpendToAdverts < ActiveRecord::Migration[6.0]
  def change
    add_column :adverts, :spend_lower_bound, :integer
    add_column :adverts, :spend_upper_bound, :integer
  end
end
