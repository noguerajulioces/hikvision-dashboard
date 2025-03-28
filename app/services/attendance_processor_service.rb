class AttendanceProcessorService
  MIN_HOURS_FOR_EXIT = 5 # Diferencia mínima para considerar una salida
  NIGHT_SHIFT_CUTOFF = 6 # Consideramos que un turno nocturno puede terminar hasta las 6 AM

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
    puts "Starting to process attendance records"
  
    events = Event.where(processed: false)
                  .where(in_out: "IN")
                  .order(:employee_id, :date, :time)
  
    events.group_by(&:employee_id).each do |employee_id, employee_events|
      grouped_by_day = employee_events.group_by(&:date)
  
      grouped_by_day.each do |date, events_on_date|
        entry = events_on_date.last
        entry_datetime = DateTime.parse("#{entry.date} #{entry.time}")
  
        # Buscar una posible salida después de la medianoche hasta NIGHT_SHIFT_CUTOFF
        possible_next_day_events = grouped_by_day[date + 1]
        exit_event = nil
  
        if possible_next_day_events.present?
          exit_event = possible_next_day_events.find do |e|
            e.time.hour <= NIGHT_SHIFT_CUTOFF
          end
        end
  
        if exit_event
          exit_datetime = DateTime.parse("#{exit_event.date} #{exit_event.time}")
          if (exit_datetime - entry_datetime) * 24 >= MIN_HOURS_FOR_EXIT
            save_attendance_record(employee_id, entry_datetime, exit_datetime)
            (events_on_date + [exit_event]).each { |e| e.update(processed: true) }
            next
          end
        end
  
        # Caso alternativo: verificar si hay otra entrada el mismo día con 5h de diferencia
        fallback_exit = events_on_date.first
        fallback_exit_datetime = DateTime.parse("#{fallback_exit.date} #{fallback_exit.time}")
        if (fallback_exit_datetime - entry_datetime) * 24 >= MIN_HOURS_FOR_EXIT
          save_attendance_record(employee_id, entry_datetime, fallback_exit_datetime)
        else
          save_attendance_record(employee_id, entry_datetime, nil)
        end
  
        events_on_date.each { |e| e.update(processed: true) }
      end
    end
  end
  
  def valid_exit?(entry_datetime, exit_datetime)
    return false if exit_datetime <= entry_datetime

    hours_diff = (exit_datetime - entry_datetime) * 24

    # Caso 1: diferencia suficiente
    return true if hours_diff >= MIN_HOURS_FOR_EXIT

    # Caso 2: turno nocturno
    entry_datetime.hour >= 20 && exit_datetime.hour <= NIGHT_SHIFT_CUTOFF
  end

  def save_attendance_record(employee_id, entry_datetime, exit_datetime)
    puts "Attempting to save attendance record for employee #{employee_id}"

    attendance = AttendanceRecord.find_or_initialize_by(
      employee_id: employee_id,
      entry_time: entry_datetime
    )

    puts "Setting device ID and exit time"
    attendance.device_id = Device.first.id
    attendance.exit_time = exit_datetime

    if attendance.save
      @processed_count += 1
      puts "✅ Registro de asistencia guardado para empleado #{employee_id}: Entrada #{entry_datetime}, Salida #{exit_datetime || 'N/A'}"
    else
      puts "⚠️ Error guardando `AttendanceRecord`: #{attendance.errors.full_messages.join(', ')}"
    end
  end
end
