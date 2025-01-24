class ReportService
  def initialize(start_date: nil, end_date: nil, employee: nil, lunch_time: nil, overtime_rate: nil, hourly_rate: nil)
    @start_date = start_date
    @end_date = end_date 
    @employee = employee
    @overtime_rate = overtime_rate || 15.0 # Tarifa por defecto para horas extra
    @hourly_rate = hourly_rate || 10.0 # Tarifa por defecto por hora
    @lunch_time = lunch_time
  end

  def get_attendance_record
    fetch_records
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
end
