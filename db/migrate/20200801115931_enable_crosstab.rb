class EnableCrosstab < ActiveRecord::Migration[6.0]
  def up
    execute 'CREATE EXTENSION tablefunc;'
  end

  def down
    execute 'DROP EXTENSION tablefunc;'
  end
end
