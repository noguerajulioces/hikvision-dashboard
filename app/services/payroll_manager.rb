class PayrollManager
  def initialize(employee, start_date, end_date)
    @employee = employee
    @start_date = start_date
    @end_date = end_date
  end

  def create_payroll
    Payroll.create!(
      employee: @employee,
      start_date: @start_date,
      end_date: @end_date
    )
  end

  def link_related_records(payroll)
    attendance_records = AttendanceRecord.where(
      employee_id: payroll.employee_id,
      entry_time: payroll.start_date.beginning_of_day..payroll.end_date.end_of_day
    )
    overtime_records = OvertimeRecord.where(
      employee_id: payroll.employee_id,
      date: payroll.start_date..payroll.end_date
    )
    incidents = Incident.where(
      employee_id: payroll.employee_id,
      date: payroll.start_date..payroll.end_date
    )

    (attendance_records + overtime_records + incidents).each do |record|
      PayrollEntry.create!(payroll: payroll, recordable: record)
    end
  end
end
