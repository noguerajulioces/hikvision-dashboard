class AddHireDateToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :hire_date, :date
  end
end
