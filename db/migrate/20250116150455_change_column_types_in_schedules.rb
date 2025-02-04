class ChangeColumnTypesInSchedules < ActiveRecord::Migration[8.0]
  def change
    change_column :schedules, :day_of_week, :integer, using: 'day_of_week::integer'
    change_column :schedules, :group_id, :bigint
  end
end
