class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.integer :group_id
      t.string :day_of_week
      t.time :expected_entry_time
      t.time :expected_exit_time

      t.timestamps
    end
  end
end
