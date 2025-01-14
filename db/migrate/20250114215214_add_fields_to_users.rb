class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :phone, :string
    add_column :users, :active, :boolean
  end
end
