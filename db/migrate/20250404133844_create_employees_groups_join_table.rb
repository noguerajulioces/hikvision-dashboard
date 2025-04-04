class CreateEmployeesGroupsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :employees, :groups do |t|
      t.index [ :employee_id, :group_id ], unique: true
      t.index [ :group_id, :employee_id ]
    end
  end
end
