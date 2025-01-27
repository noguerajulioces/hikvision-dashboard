class ReplaceDayOfWeekWithDateInSchedules < ActiveRecord::Migration[8.0]
  def change
    remove_column :schedules, :day_of_week, :integer
    add_column :schedules, :date, :date, null: false
    add_index :schedules, [:group_id, :date], unique: true
  end
end
