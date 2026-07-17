class AttendanceProcessorService
  # Un turno real dura ~8h (19:50 → 04:00); pasada esta ventana la salida se da por perdida.
  SERENO_MAX_SHIFT_HOURS = 14
  # Golpes más cercanos que esto son re-marcaciones del mismo ingreso, no un turno.
  SERENO_MIN_SHIFT_HOURS = 4

  def initialize
    @processed_count = 0
    @first_device_id = Device.first&.id
  end

  def call
    puts "🔄 Iniciando procesamiento de eventos..."
    process_all_employees
    puts "✅ Procesamiento completo. Registros creados: #{@processed_count}"
  end

  private

  def process_all_employees
    grouped_events = Event
                      .where(processed: false)
                      .where.not(employee_id: nil)
                      .reorder(:employee_id, :date, :time)
                      .group_by(&:employee_id)

    grouped_events.each do |employee_id, events|
      create_attendance_for_employee(employee_id, events)
    end
  end

  def create_attendance_for_employee(employee_id, events)
    employee = Employee.find_by(id: employee_id)

    unless employee
      log_missing_employee(employee_id, events)
      mark_events_as_processed(events)
      return
    end

    sorted_events = valid_events(events).sort_by { |e| [ e.date, e.time ] }

    if employee.sereno?
      process_sereno_events(employee, sorted_events)
    else
      handle_standard_attendance(employee, sorted_events)
    end
  end

  # El sereno marca al entrar (~20:00) y al salir (~04:00 del día siguiente), a veces
  # con re-marcaciones. Recorremos sus eventos como un stream cronológico: el primer
  # evento no consumido abre un turno y el último golpe dentro de la ventana de
  # SERENO_MAX_SHIFT_HOURS lo cierra; los golpes intermedios son re-marcaciones.
  # Así una salida matinal nunca puede volver a usarse como entrada del día siguiente.
  def process_sereno_events(employee, events)
    index = 0

    while index < events.length
      entry_event = events[index]
      entry_time = build_datetime(entry_event)

      window = shift_window(events, index, entry_time)
      exit_event = window.last

      if exit_event && hours_between(entry_time, build_datetime(exit_event)) >= SERENO_MIN_SHIFT_HOURS
        create_attendance_record(employee.id, entry_time, build_datetime(exit_event), [ entry_event, *window ])
      elsif index + window.length + 1 >= events.length
        # La entrada (y sus re-marcaciones) son la cola del stream: la salida puede
        # llegar en la próxima importación, así que quedan pendientes (processed: false).
        break
      else
        # El siguiente golpe está a más de SERENO_MAX_SHIFT_HOURS: salida perdida.
        create_attendance_record(employee.id, entry_time, nil, [ entry_event, *window ])
      end

      index += 1 + window.length
    end
  end

  def shift_window(events, index, entry_time)
    events[(index + 1)..].take_while do |event|
      hours_between(entry_time, build_datetime(event)) <= SERENO_MAX_SHIFT_HOURS
    end
  end

  def hours_between(from, to)
    ((to - from) * 24).to_f
  end

  def handle_standard_attendance(employee, events)
    return if events.empty?

    events.group_by(&:date).sort.each do |_date, day_events|
      sorted_day_events = day_events.sort_by(&:time)

      entry_time = build_datetime(sorted_day_events.first)
      exit_time  = build_datetime(sorted_day_events.last)

      # Verificamos si la diferencia es al menos 5 horas
      hours_diff = ((exit_time - entry_time) * 24).to_f
      exit_time = nil if hours_diff < 5

      # El registro consume TODOS los golpes del día: los intermedios son
      # re-marcaciones de la misma jornada y, si quedaran pendientes, la próxima
      # corrida los convertiría en registros basura "sin salida".
      create_attendance_record(employee.id, entry_time, exit_time, sorted_day_events)
    end
  end

  def valid_events(events)
    # Ajustá esto si tenés un campo como `valid: boolean`
    events.reject { |e| e.try(:valid) == false }
  end

  def create_attendance_record(employee_id, entry_time, exit_time, events)
    attendance = AttendanceRecord.find_or_initialize_by(
      employee_id: employee_id,
      entry_time: entry_time
    )

    # Nunca degradar un registro que ya tiene salida: un reproceso sin la salida
    # a la vista (p. ej. una re-importación parcial) no debe borrar datos buenos.
    if attendance.persisted? && attendance.exit_time.present? && exit_time.nil?
      mark_events_as_processed(events)
      return
    end

    attendance.exit_time = exit_time
    attendance.device_id = first_device_id

    if attendance.save
      @processed_count += 1
      mark_events_as_processed(events)
      log_success(employee_id, entry_time, exit_time)
    else
      log_error(employee_id, attendance)
    end
  end

  def build_datetime(event)
    DateTime.parse("#{event.date} #{event.time}")
  end

  attr_reader :first_device_id

  def mark_events_as_processed(events)
    ids = events.map(&:id)
    return if ids.empty?

    Event.where(id: ids).update_all(processed: true, updated_at: Time.current)
  end

  def log_success(employee_id, entry_time, exit_time)
    puts "✅ Guardado: #{employee_id} - Entrada: #{entry_time}, Salida: #{exit_time}"
  end

  def log_error(employee_id, attendance)
    puts "⚠️ Error para #{employee_id}: #{attendance.errors.full_messages.join(', ')}"
  end

  def log_missing_employee(employee_id, events)
    puts "⚠️ Empleado con ID #{employee_id} no encontrado o eliminado. Se omitirán #{events.count} eventos."
  end
end
