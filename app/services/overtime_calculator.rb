
class OvertimeCalculator
  def initialize(record, schedule, lunch_time)
    @record = record
    @schedule = schedule
    @lunch_time = lunch_time
  end

  def calculate_overtime_hours
    return 0 unless @record.exit_time > @schedule.expected_exit_time

    # Calculate overtime only from expected exit time to actual exit time
    overtime_hours = (@record.exit_time - @schedule.expected_exit_time) / 3600.0

    # If overtime period includes lunch time and is over 4 hours, subtract lunch
    overtime_hours -= lunch_hours if @lunch_time && overtime_hours > 4

    [overtime_hours, 0].max
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
