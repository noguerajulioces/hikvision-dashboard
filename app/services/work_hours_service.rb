class WorkHoursService
  def initialize(employee_id, start_date, end_date, lunch_time = false)
    @employee = Employee.find(employee_id)
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @lunch_time = lunch_time
  end

  def process_overtime
    records = @employee.unprocessed_attendance_records(@start_date, @end_date)

    records.each do |record|
      # Buscar el horario correspondiente al grupo del empleado y la fecha
      schedule = Schedule.find_by(group_id: @employee.group_id, date: record.entry_time.to_date)

      # Validar si existe un horario para el día
      if schedule.nil?
        Incident.create!(
          employee: @employee,
          date: record.entry_time.to_date,
          issue: "No se encontró horario para este día"
        )
        next
      end

      # Verificar si el empleado llegó tarde (con tolerancia de 5 minutos)
      if record.entry_time.to_time > schedule.expected_entry_time + 5.minutes
        Incident.create!(
          employee: @employee,
          date: record.entry_time.to_date,
          issue: "Llegó tarde"
        )
      end

      # Calcular horas extras si tiene hora de salida
      if record.exit_time.nil?
        Incident.create!(
          employee: @employee,
          date: record.entry_time.to_date,
          issue: "No se registró hora de salida"
        )
      else
        hours = calculate_overtime_hours(record, schedule)
        compensation = hours * 20_000 # Ejemplo de cálculo de compensación

        if hours > 0
          OvertimeRecord.create!(
            employee: @employee,
            date: record.entry_time.to_date,
            hours_worked: hours,
            compensation: compensation
          )
        end
      end

      # Marcar el registro como procesado
      record.update(processed: true)
    end
  end

  private

  def calculate_overtime_hours(record, schedule)
    total_hours = (record.exit_time - record.entry_time) / 3600.0

    # Restar hora de almuerzo si corresponde
    if @lunch_time && total_hours > 4
      total_hours -= 1
    end

    # Las horas extras se calculan en base al horario esperado de salida
    expected_work_hours = (schedule.expected_exit_time - schedule.expected_entry_time) / 3600.0
    [total_hours - expected_work_hours, 0].max
  end
end
