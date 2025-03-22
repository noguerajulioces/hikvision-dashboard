class AttendanceProcessor
  def initialize(record, employee, lunch_time)
    @record = record
    @employee = employee
    @lunch_time = lunch_time
  end

  def process
    schedule = find_schedule(@record)
    return unless schedule

    handle_lateness(schedule)
    handle_exit_time(schedule)

    @record.update(processed: true)
  end

  private

  def find_schedule(record)
    schedule = Schedule.find_by(group_id: @employee.group_id, date: record.entry_time.to_date)
    unless schedule
      IncidentManager.new(@employee).create_incident(record, "No se encontró horario para este día")
    end
    schedule
  end

  def handle_lateness(schedule)
    if @record.entry_time.to_time > schedule.expected_entry_time + margin_of_tolerance
      delay_minutes = ((@record.entry_time.to_time - schedule.expected_entry_time) / 60).round
      IncidentManager.new(@employee).create_incident(@record, "Llegó tarde (#{delay_minutes} minutos)")
    end
  end

  def handle_exit_time(schedule)
    if @record.exit_time.nil?
      IncidentManager.new(@employee).create_incident(@record, "No se registró hora de salida")
    else
      hours = OvertimeCalculator.new(@record, schedule, @lunch_time).calculate_overtime_hours
      OvertimeCalculator.new(@record, schedule, @lunch_time).create_overtime_record(hours) if hours > 0
    end
  end

  def margin_of_tolerance
    AppSetting&.margin_of_tolerance&.to_i&.minutes || 5.minutes
  end
end
