class WorkHoursService
  def initialize(employee_id, start_date, end_date, lunch_time = false)
    @employee = Employee.find(employee_id)
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @lunch_time = lunch_time
  end

  def process_overtime
    records = @employee.unprocessed_attendance_records(@start_date, @end_date)

    # Crea la nómina
    payroll = PayrollManager.new(@employee, @start_date, @end_date).create_payroll

    records.each do |record|
      AttendanceProcessor.new(record, @employee, @lunch_time).process
    end

    # Vincula todos los registros relacionados después del procesamiento
    PayrollManager.new(@employee, @start_date, @end_date).link_related_records(payroll)

    payroll
  end
end
