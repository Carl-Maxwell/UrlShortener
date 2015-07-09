class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_premium, :boolean, default: false, null: false
  end
end
