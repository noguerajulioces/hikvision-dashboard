class AddIncludeLunchToSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :schedules, :include_lunch, :boolean
  end
end
