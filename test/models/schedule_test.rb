# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  date                :date             not null
#  expected_entry_time :datetime
#  expected_exit_time  :datetime
#  include_lunch       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :bigint
#
# Indexes
#
#  index_schedules_on_group_id_and_date  (group_id,date) UNIQUE
#
require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  test "a night schedule crossing midnight is valid and its effective exit falls on the next day" do
    schedule = night_schedule

    assert schedule.valid?
    assert schedule.crosses_midnight?
    assert_equal Time.zone.parse("2026-06-20 04:00:00"), schedule.effective_expected_exit_time
  end

  test "formatted_duration handles schedules crossing midnight" do
    assert_equal "08:00 horas", night_schedule.formatted_duration
  end

  test "a day schedule keeps its exit time as-is" do
    schedule = Schedule.new(
      group: Group.create!(name: "Ventas"),
      expected_entry_time: Time.zone.parse("2026-06-19 07:00:00"),
      expected_exit_time: Time.zone.parse("2026-06-19 16:00:00")
    )

    assert_not schedule.crosses_midnight?
    assert_equal schedule.expected_exit_time, schedule.effective_expected_exit_time
  end

  private
    def night_schedule
      Schedule.new(
        group: Group.create!(name: "Sereno"),
        expected_entry_time: Time.zone.parse("2026-06-19 20:00:00"),
        expected_exit_time: Time.zone.parse("2026-06-19 04:00:00")
      )
    end
end
