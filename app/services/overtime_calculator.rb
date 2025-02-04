
class OvertimeCalculator
  def initialize(record, schedule, lunch_time)
    @record = record
    @schedule = schedule
    @lunch_time = lunch_time
  end

  def calculate_overtime_hours
    total_hours = (@record.exit_time - @record.entry_time) / 3600.0

    # Restar hora de almuerzo si corresponde
    total_hours -= lunch_hours if @lunch_time && total_hours > 4

    expected_work_hours = ((@schedule.expected_exit_time - @schedule.expected_entry_time) / 3600.0) - lunch_hours if @lunch_time
    [ total_hours - expected_work_hours, 0 ].max
  end

  def create_overtime_record(hours)
    compensation = hours * overtime_rate
    OvertimeRecord.create!(
      employee: @record.employee,
      date: @record.entry_time.to_date,
      hours_worked: hours,
      compensation: compensation
    )
  end

  private

  def lunch_hours
    Setting&.lunch_hours&.to_i || 1
  end

  def overtime_rate
    Setting.overtime_rate
  end
end
