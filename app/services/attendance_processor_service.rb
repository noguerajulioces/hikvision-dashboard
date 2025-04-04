class AttendanceProcessorService
  def initialize
    @processed_count = 0
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
                      .order(:employee_id, :date, :time)
                      .group_by(&:employee_id)

    grouped_events.each do |employee_id, events|
      create_attendance_for_employee(employee_id, events)
    end
  end

  def create_attendance_for_employee(employee_id, events)
    employee = Employee.find(employee_id)
    sorted_events = valid_events(events).sort_by { |e| [e.date, e.time] }

    if sereno?(employee)
      process_sereno_events(employee, sorted_events)
    else
      process_dynamic_shifts(employee, sorted_events)
    end
  end

  def sereno?(employee)
    employee.group&.name == "Sereno"
  end

  def process_sereno_events(employee, events)
    used_event_ids = []
    events_by_date = events.group_by(&:date).sort.to_h

    events_by_date.each_with_index do |(date, day_events), idx|
      entry_event = day_events.reject { |e| used_event_ids.include?(e.id) }.last
      next unless entry_event

      next_date = events_by_date.keys[idx + 1]
      next_events = events_by_date[next_date]
      next unless next_events&.any?

      exit_event = next_events.reject { |e| used_event_ids.include?(e.id) }.first
      next unless exit_event

      entry_time = build_datetime(entry_event)
      exit_time = build_datetime(exit_event)

      create_attendance_record(employee.id, entry_time, exit_time, [entry_event, exit_event])

      used_event_ids << entry_event.id
      used_event_ids << exit_event.id
    end
  end

  def process_dynamic_shifts(employee, events)
    used_event_ids = []
    i = 0

    while i < events.length - 1
      entry_event = events[i]
      exit_event  = events[i + 1]

      # Saltar eventos ya usados
      if used_event_ids.include?(entry_event.id) || used_event_ids.include?(exit_event.id)
        i += 1
        next
      end

      entry_time = build_datetime(entry_event)
      exit_time = build_datetime(exit_event)

      # Si el turno parece cruzar medianoche
      if is_night_shift?(entry_time, exit_time)
        create_attendance_record(employee.id, entry_time, exit_time, [entry_event, exit_event])
        used_event_ids << entry_event.id
        used_event_ids << exit_event.id
        i += 2
      else
        # Si es un turno normal, lo emparejamos si el exit es el último evento del día
        same_day = entry_time.to_date == exit_time.to_date
        if same_day
          create_attendance_record(employee.id, entry_time, exit_time, [entry_event, exit_event])
          used_event_ids << entry_event.id
          used_event_ids << exit_event.id
          i += 2
        else
          i += 1
        end
      end
    end
  end

  def is_night_shift?(entry_time, exit_time)
    entry_hour = entry_time.hour
    exit_hour = exit_time.hour

    # Consideramos turno nocturno si comienza >= 21 y termina <= 6 del día siguiente
    entry_hour >= 21 && exit_time > entry_time && (exit_hour <= 6 || exit_time.to_date > entry_time.to_date)
  end

  def valid_events(events)
    # Ajustá si tenés un campo tipo `valid: boolean`
    events.reject { |e| e.try(:valid) == false }
  end

  def create_attendance_record(employee_id, entry_time, exit_time, events)
    attendance = AttendanceRecord.find_or_initialize_by(
      employee_id: employee_id,
      entry_time: entry_time
    )

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

  def first_device_id
    Device.first&.id
  end

  def mark_events_as_processed(events)
    events.each { |e| e.update(processed: true) }
  end

  def log_success(employee_id, entry_time, exit_time)
    puts "✅ Guardado: #{employee_id} - Entrada: #{entry_time}, Salida: #{exit_time}"
  end

  def log_error(employee_id, attendance)
    puts "⚠️ Error para #{employee_id}: #{attendance.errors.full_messages.join(', ')}"
  end
end
