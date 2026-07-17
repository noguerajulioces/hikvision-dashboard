require "test_helper"

class OvertimeCalculatorTest < ActiveSupport::TestCase
  setup do
    # AppSetting.[]= está roto (ver workaround en Admin::SettingsController); insertamos directo.
    now = Time.current
    AppSetting.insert({ key: "overtime_rate", value: "1000", created_at: now, updated_at: now })
    AppSetting.insert({ key: "margin_of_tolerance", value: "5", created_at: now, updated_at: now })

    @sereno = Employee.create!(document_number: "3489327", group: Group.create!(name: "Sereno"))
    @night_schedule = Schedule.create!(
      group: @sereno.group,
      expected_entry_time: Time.zone.parse("2026-06-19 20:00:00"),
      expected_exit_time: Time.zone.parse("2026-06-19 04:00:00")
    )
  end

  test "a normal night shift produces no overtime" do
    record = attendance(entry: "2026-06-19 19:55:00", exit: "2026-06-20 03:50:00")

    assert_equal 0, OvertimeCalculator.new(record, @night_schedule, false).calculate_overtime_hours
  end

  test "leaving after the effective morning exit produces the real extra hours" do
    record = attendance(entry: "2026-06-19 19:55:00", exit: "2026-06-20 05:30:00")

    hours = OvertimeCalculator.new(record, @night_schedule, false).calculate_overtime_hours
    assert_in_delta 1.5, hours, 0.01
  end

  test "day schedules keep their overtime behavior" do
    worker = Employee.create!(document_number: "5058650", group: Group.create!(name: "Ventas"))
    day_schedule = Schedule.create!(
      group: worker.group,
      expected_entry_time: Time.zone.parse("2026-06-19 07:00:00"),
      expected_exit_time: Time.zone.parse("2026-06-19 16:00:00")
    )
    record = AttendanceRecord.create!(
      employee: worker,
      device: devices(:one),
      entry_time: Time.zone.parse("2026-06-19 07:00:00"),
      exit_time: Time.zone.parse("2026-06-19 18:00:00")
    )

    hours = OvertimeCalculator.new(record, day_schedule, false).calculate_overtime_hours
    assert_in_delta 2.0, hours, 0.01
  end

  private
    def attendance(entry:, exit:)
      AttendanceRecord.create!(
        employee: @sereno,
        device: devices(:one),
        entry_time: Time.zone.parse(entry),
        exit_time: Time.zone.parse(exit)
      )
    end
end
