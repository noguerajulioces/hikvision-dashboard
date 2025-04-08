class DropEmployeesGroupsJoinTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :employees_groups
  end
end
