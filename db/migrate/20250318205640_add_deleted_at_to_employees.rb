class AddDeletedAtToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :deleted_at, :datetime
    add_index  :employees, :deleted_at
  end
end
