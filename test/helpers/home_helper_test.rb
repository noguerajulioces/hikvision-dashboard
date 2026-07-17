require "test_helper"

class HomeHelperTest < ActionView::TestCase
  test "schedule_shift_distribution buckets schedules by local entry hour" do
    day_group = Group.create!(name: "Ventas")
    night_group = Group.create!(name: "Sereno - Diosnel")

    create_schedule day_group, "2026-07-13 07:00", "2026-07-13 16:00"
    create_schedule day_group, "2026-07-14 13:00", "2026-07-14 18:00"
    create_schedule night_group, "2026-07-13 20:00", "2026-07-13 04:00"

    assert_equal({ morning: 1, afternoon: 1, night: 1 }, schedule_shift_distribution)
  end

  private
    def create_schedule(group, entry, exit_time)
      Schedule.create!(
        group: group,
        expected_entry_time: Time.zone.parse(entry),
        expected_exit_time: Time.zone.parse(exit_time)
      )
    end
end
