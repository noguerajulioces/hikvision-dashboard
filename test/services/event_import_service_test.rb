require "test_helper"

class EventImportServiceTest < ActiveSupport::TestCase
  test "imports device rows and auto-creates employees by document" do
    result = EventImportService.new(file_fixture("sereno_events.csv").to_s).call

    assert_equal 4, result[:total_imported]
    assert_equal 0, result[:skipped_duplicates]
    assert_empty result[:errors]

    assert Employee.exists?(document_number: "3489327")
    assert_equal "3489327", Event.find_by(serial_no: 51925).s_job_no
  end

  test "rows without a real document create no employee and no attendance" do
    EventImportService.new(file_fixture("sereno_events.csv").to_s).call

    failed_read = Event.find_by(serial_no: 51804)
    assert_nil failed_read.employee_id
    assert_not Employee.exists?(document_number: "")
    assert_not AttendanceRecord.exists?(entry_time: Time.zone.parse("2026-06-19 13:44:53"))
  end

  test "re-importing the same file skips every row as duplicate" do
    EventImportService.new(file_fixture("sereno_events.csv").to_s).call
    events_before = Event.count
    records_before = AttendanceRecord.count

    result = EventImportService.new(file_fixture("sereno_events.csv").to_s).call

    assert_equal 0, result[:total_imported]
    assert_equal 4, result[:skipped_duplicates]
    assert_empty result[:errors]
    assert_equal events_before, Event.count
    assert_equal records_before, AttendanceRecord.count
  end
end
