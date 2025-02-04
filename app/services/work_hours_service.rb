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
      process_record(record)
    end
  end

  private

  # Procesar cada registro de asistencia
  def process_record(record)
    schedule = find_schedule(record)
    return unless schedule

    # Procesa las llegadas tarde comparando la hora de entrada con la hora esperada
    handle_lateness(record, schedule)
    # Maneja el tiempo de salida
    handle_exit_time(record, schedule)

    record.update(processed: true)
  end

  # Encontrar el horario correspondiente
  def find_schedule(record)
    schedule = Schedule.find_by(group_id: @employee.group_id, date: record.entry_time.to_date)
    unless schedule
      create_incident(record, "No se encontró horario para este día")
    end
    schedule
  end

  # Manejar llegadas tarde
  def handle_lateness(record, schedule)
    if record.entry_time.to_time > schedule.expected_entry_time + margin_of_tolerance
      delay_minutes = ((record.entry_time.to_time - schedule.expected_entry_time) / 60).round
      create_incident(record, "Llegó tarde (#{delay_minutes} minutos)")
    end
  end

  # Manejar horas extras o falta de hora de salida
  def handle_exit_time(record, schedule)
    if record.exit_time.nil?
      create_incident(record, "No se registró hora de salida")
    else
      hours = calculate_overtime_hours(record, schedule)
      create_overtime_record(record, hours) if hours > 0
    end
  end

  # Calcular horas extras
  def calculate_overtime_hours(record, schedule)
    total_hours = (record.exit_time - record.entry_time) / 3600.0

    # Restar hora de almuerzo si corresponde
    total_hours -= lunch_hours if @lunch_time && total_hours > 4

    # Horas extras en base al horario esperado
    expected_work_hours = ((schedule.expected_exit_time - schedule.expected_entry_time) / 3600.0) - lunch_hours if @lunch_time 
    [ total_hours - expected_work_hours, 0 ].max
  end

  # Crear registro de horas extras
  def create_overtime_record(record, hours)
    compensation = hours * overtime_rate
    OvertimeRecord.create!(
      employee: @employee,
      date: record.entry_time.to_date,
      hours_worked: hours,
      compensation: compensation
    )
  end

  # Crear incidente
  def create_incident(record, issue)
    Incident.create!(
      employee: @employee,
      date: record.entry_time.to_date,
      issue: issue
    )
  end

  # Configuraciones de tolerancia y tarifas
  def margin_of_tolerance
    Setting&.margin_of_tolerance&.to_i&.minutes || 5.minutes
  end

  def lunch_hours
    Setting&.lunch_hours&.to_i || 1
  end

  def overtime_rate
    Setting.overtime_rate
  end
end
