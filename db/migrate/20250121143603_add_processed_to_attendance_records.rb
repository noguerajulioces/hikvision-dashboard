class AddProcessedToAttendanceRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :attendance_records, :processed, :boolean
  end
end
