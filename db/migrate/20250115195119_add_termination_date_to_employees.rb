class AddTerminationDateToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :termination_date, :date
  end
end
