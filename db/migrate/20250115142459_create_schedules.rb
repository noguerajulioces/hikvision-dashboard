class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.integer :group_id
      t.string :day_of_week
      t.datetime :expected_entry_time
      t.datetime :expected_exit_time

      t.timestamps
    end
  end
end
