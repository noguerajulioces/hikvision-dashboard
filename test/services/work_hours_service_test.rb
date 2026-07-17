require "test_helper"

class WorkHoursServiceTest < ActiveSupport::TestCase
  setup do
    # AppSetting.[]= está roto (ver workaround en Admin::SettingsController); insertamos directo.
    now = Time.current
    AppSetting.insert({ key: "overtime_rate", value: "1000", created_at: now, updated_at: now })

    @sereno = Employee.create!(document_number: "3489327", group: Group.create!(name: "Sereno"))
    create_night_schedule("2026-06-19")
    create_night_schedule("2026-06-20")

    AttendanceRecord.create!(
      employee: @sereno,
      device: devices(:one),
      entry_time: Time.zone.parse("2026-06-19 19:54:00"),
      exit_time: Time.zone.parse("2026-06-20 03:59:00")
    )
  end

  test "the morning after the last worked night is not flagged as absent for a sereno" do
    WorkHoursService.new(@sereno.id, "2026-06-19", "2026-06-20").process_overtime

    assert_empty absence_incidents
  end

  test "a scheduled night with no attendance at all still creates the incident" do
    create_night_schedule("2026-06-21")

    WorkHoursService.new(@sereno.id, "2026-06-19", "2026-06-21").process_overtime

    assert_equal [ Date.parse("2026-06-21") ], absence_incidents.map(&:date)
  end

  test "a normal night shift generates no overtime records" do
    WorkHoursService.new(@sereno.id, "2026-06-19", "2026-06-20").process_overtime

    assert_empty @sereno.overtime_records
  end

  private
    def create_night_schedule(date)
      Schedule.create!(
        group: @sereno.group,
        expected_entry_time: Time.zone.parse("#{date} 20:00:00"),
        expected_exit_time: Time.zone.parse("#{date} 04:00:00")
      )
    end

    def absence_incidents
      @sereno.incidents.where("issue LIKE ?", "No se presentó%")
    end
end
