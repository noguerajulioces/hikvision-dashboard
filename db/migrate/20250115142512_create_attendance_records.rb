class CreateAttendanceRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :attendance_records do |t|
      t.integer :employee_id
      t.datetime :entry_time
      t.datetime :exit_time
      t.integer :device_id

      t.timestamps
    end
  end
end
