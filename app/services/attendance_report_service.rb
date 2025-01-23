class AttendanceReportService
  def initialize(employee, start_date, end_date)
    @employee = employee
    @start_date = start_date
    @end_date = end_date
  end

  def generate_report
    records = @employee.unprocessed_attendance_records(@start_date, @end_date)
    worked_hours = @employee.calculate_worked_hours(records)
    overtime = @employee.calculate_overtime(records)

    {
      employee_full_name: @employee&.full_name,
      total_worked_hours: worked_hours,
      total_overtime_hours: overtime,
      pay_due: calculate_pay_due(worked_hours, overtime)
    }
  end

  private

  def calculate_pay_due(worked_hours, overtime_hours)
    # Suponiendo que tienes un método para obtener la tarifa por hora y la tarifa de horas extras
    hourly_rate = 5 # @employee&.hourly_rate || 5
    overtime_rate = @employee&.overtime_records.count || 2

    (worked_hours * hourly_rate) + (overtime_hours * overtime_rate)
  end
end
