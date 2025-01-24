class OvertimeService
  def initialize(start_date: nil, end_date: nil, employee: nil, overtime_rate: nil)
    @start_date = start_date
    @end_date = end_date
    @employee = employee
    @overtime_rate = overtime_rate || 15.0
  end

  def get_overtime_rate
    attendance_records = fetch_records
    overtime_records = []

    attendance_records.group_by { |r| r.entry_time.to_date }.each do |date, daily_records|
      total_hours = calculate_daily_hours(daily_records)
      
      if total_hours > 8
        overtime_hours = total_hours - 8
        compensation = overtime_hours * @overtime_rate

        overtime_records << OvertimeRecord.new(
          employee: @employee,
          date: date,
          hours_worked: overtime_hours,
          compensation: compensation
        )
      end
    end

    overtime_records
  end

  private

  def fetch_records
    scope = AttendanceRecord.where(processed: false)
    scope = scope.where(employee: @employee) if @employee
    scope = scope.where(entry_time: @start_date..@end_date) if @start_date && @end_date
    scope
  end

  def calculate_daily_hours(records)
    total_hours = 0
    records.each do |record|
      if record.exit_time
        hours = (record.exit_time - record.entry_time) / 3600
        total_hours += hours
      end
    end
    total_hours
  end
end