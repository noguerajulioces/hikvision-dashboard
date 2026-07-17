require "test_helper"

class TimeMetricsServiceTest < ActiveSupport::TestCase
  setup do
    @group = Group.create!(name: "Ventas")
    @employee = Employee.create!(document_number: "5058650", group: @group)
    Schedule.create!(
      group: @group,
      expected_entry_time: Time.zone.parse("#{Date.today} 07:00"),
      expected_exit_time: Time.zone.parse("#{Date.today} 16:00")
    )
  end

  test "punctuality compares entries against the schedule with 15 minutes of tolerance" do
    record_for @employee, entry: "07:05"

    late = Employee.create!(document_number: "7444871", group: @group)
    record_for late, entry: "07:40"

    assert_equal 50, TimeMetricsService.new("today").calculate[:punctuality_rate]
  end

  test "absence rate counts expected attendances from scheduled groups" do
    Employee.create!(document_number: "7444871", group: @group)
    record_for @employee, entry: "07:05"

    # 1 horario hoy x 2 empleados del grupo = 2 esperadas; 1 asistencia -> 50%
    assert_equal 50, TimeMetricsService.new("today").calculate[:absence_rate]
  end

  private
    def record_for(employee, entry:)
      AttendanceRecord.create!(
        employee: employee,
        device: devices(:one),
        entry_time: Time.zone.parse("#{Date.today} #{entry}"),
        exit_time: Time.zone.parse("#{Date.today} 16:00")
      )
    end
end
