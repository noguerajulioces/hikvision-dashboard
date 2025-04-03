class AttendanceProcessorService
  MIN_HOURS_FOR_EXIT = 5
  NIGHT_SHIFT_CUTOFF = 6

  def initialize
    puts "Initializing AttendanceProcessorService"
    @processed_count = 0
  end

  def call
    puts "Starting attendance processing"
    process_attendance
    puts "✅ Procesamiento completado. Registros procesados: #{@processed_count}"
  end

  private

  def process_attendance
    grouped_events = fetch_and_group_events

    grouped_events.each do |employee_id, events_by_day|
      events_by_day.each do |date, events_on_date|
        entry = events_on_date.last
        entry_datetime = datetime_from_event(entry)

        exit_event = find_next_day_exit(events_by_day, date)

        if exit_event
          exit_datetime = datetime_from_event(exit_event)

          if valid_exit?(entry_datetime, exit_datetime)
            save_attendance_record(employee_id, entry_datetime, exit_datetime)
            mark_events_as_processed(events_on_date + [exit_event])
            next
          end
        end

        fallback_exit = events_on_date.first
        fallback_exit_datetime = datetime_from_event(fallback_exit)

        if valid_exit?(entry_datetime, fallback_exit_datetime)
          save_attendance_record(employee_id, entry_datetime, fallback_exit_datetime)
        else
          save_attendance_record(employee_id, entry_datetime, nil)
        end

        mark_events_as_processed(events_on_date)
      end
    end
  end

  def fetch_and_group_events
    Event.where(processed: false, in_out: "IN")
         .order(:employee_id, :date, :time)
         .group_by(&:employee_id)
         .transform_values { |events| events.group_by(&:date) }
  end

  def datetime_from_event(event)
    DateTime.parse("#{event.date} #{event.time}")
  end

  def find_next_day_exit(events_by_day, date)
    next_day_events = events_by_day[date + 1]
    return nil unless next_day_events.present?

    next_day_events.find { |e| e.time.hour <= NIGHT_SHIFT_CUTOFF }
  end

  def valid_exit?(entry_datetime, exit_datetime)
    return false if exit_datetime <= entry_datetime

    hours_diff = (exit_datetime - entry_datetime) * 24
    return true if hours_diff >= MIN_HOURS_FOR_EXIT

    # turno nocturno
    entry_datetime.hour >= 20 && exit_datetime.hour <= NIGHT_SHIFT_CUTOFF
  end

  def save_attendance_record(employee_id, entry_datetime, exit_datetime)
    puts "Attempting to save attendance record for employee #{employee_id}"

    attendance = AttendanceRecord.find_or_initialize_by(
      employee_id: employee_id,
      entry_time: entry_datetime
    )

    attendance.device_id = Device.first.id
    attendance.exit_time = exit_datetime

    if attendance.save
      @processed_count += 1
      puts "✅ Registro de asistencia guardado para empleado #{employee_id}: Entrada #{entry_datetime}, Salida #{exit_datetime || 'N/A'}"
    else
      puts "⚠️ Error guardando `AttendanceRecord`: #{attendance.errors.full_messages.join(', ')}"
    end
  end

  def mark_events_as_processed(events)
    events.each { |e| e.update(processed: true) }
  end
end
