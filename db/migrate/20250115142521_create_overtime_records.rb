class CreateOvertimeRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :overtime_records do |t|
      t.integer :employee_id
      t.date :date
      t.decimal :hours_worked
      t.decimal :compensation

      t.timestamps
    end
  end
end
