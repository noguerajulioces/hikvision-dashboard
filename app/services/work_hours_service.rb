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

    # Verifica días sin asistencia y crea incidentes para esos casos
    verify_missing_attendance

    # Vincula todos los registros relacionados después del procesamiento
    PayrollManager.new(@employee, @start_date, @end_date).link_related_records(payroll)

    payroll
  end

  private

  # Método que verifica si existen schedules sin registro de asistencia en el rango
  def verify_missing_attendance
    # Obtiene todos los schedules para el grupo del empleado en el rango de fechas
    schedules = Schedule.where(group_id: @employee.group_id, date: @start_date..@end_date)
    return if schedules.empty?

    # Cargamos las fechas con asistencia del rango en una sola consulta, en lugar
    # de ejecutar un `exists?` por cada schedule.
    punches = @employee.attendance_records
                       .where(entry_time: @start_date.beginning_of_day..@end_date.end_of_day)
                       .pluck(:entry_time, :exit_time)

    attended_dates = punches.map { |entry_time, _| entry_time.to_date }.to_set

    # El turno del sereno cruza la medianoche: la mañana en que sale también cuenta
    # como fecha asistida, para no marcar "No se presentó" el día posterior a su
    # última noche trabajada cuando hay horarios cargados en bloque.
    if @employee.sereno?
      attended_dates.merge(punches.filter_map { |_, exit_time| exit_time&.to_date })
    end

    schedules.each do |schedule|
      next if attended_dates.include?(schedule.date)

      # Si no se encontró ningún registro, se crea el incidente correspondiente.
      IncidentManager.new(@employee).create_incident(
        schedule,
        "No se presentó para el horario del #{schedule.date} a las #{schedule.expected_entry_time.strftime('%H:%M')}"
      )
    end
  end
end
