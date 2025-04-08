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
    sorted_events = valid_events(events).sort_by { |e| [ e.date, e.time ] }
  
    if sereno?(employee)
      process_sereno_events(employee, sorted_events)
    else
      handle_standard_attendance(employee, sorted_events)
    end
  end

  def sereno?(employee)
    employee.group&.name&.downcase == 'sereno'
  end

  def process_sereno_events(employee, events)
    used_entry_ids = []
    used_exit_ids = []
    events_by_date = events.group_by(&:date).sort.to_h

    events_by_date.each_with_index do |(date, day_events), idx|
      entry_event = day_events.reject { |e| used_entry_ids.include?(e.id) }.last
      next unless entry_event

      next_date = events_by_date.keys[idx + 1]
      next_events = events_by_date[next_date]
      next unless next_events&.any?

      exit_event = next_events.reject { |e| used_exit_ids.include?(e.id) }.first
      next unless exit_event

      entry_time = build_datetime(entry_event)
      exit_time = build_datetime(exit_event)

      hours_diff = ((exit_time - entry_time) * 24).to_f

      if hours_diff > 14
        # si se pasa de las 14 horas, lo marcamos como sin salida, pero NO usamos el exit_event
        create_attendance_record(employee.id, entry_time, nil, [ entry_event ])
        used_entry_ids << entry_event.id
        next
      end

      create_attendance_record(employee.id, entry_time, exit_time, [ entry_event, exit_event ])
      used_entry_ids << entry_event.id
      used_exit_ids << exit_event.id
    end
  end

  def handle_standard_attendance(employee, events)
    return if events.empty?
  
    events_by_date = events.group_by(&:date).sort.to_h
    used_event_ids = []
  
    events_by_date.each do |_date, day_events|
      sorted_day_events = day_events.reject { |e| used_event_ids.include?(e.id) }.sort_by(&:time)
      next if sorted_day_events.empty?
  
      entry_event = sorted_day_events.first
      exit_event  = sorted_day_events.last
  
      entry_time = build_datetime(entry_event)
      exit_time  = build_datetime(exit_event)

      # Verificamos si la diferencia es al menos 5 horas
      hours_diff = ((exit_time - entry_time) * 24).to_f
      exit_time = nil if hours_diff < 5

      create_attendance_record(employee.id, entry_time, exit_time, [entry_event, exit_event].uniq)

      used_event_ids << entry_event.id
      used_event_ids << exit_event.id if exit_time
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
