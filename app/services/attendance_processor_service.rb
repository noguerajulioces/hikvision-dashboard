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

    # Obtener solo eventos NO procesados, ordenados por empleado y fecha/hora DESC (por default_scope)
    events = Event.where(processed: false)
                  .where(in_out: "IN") # Solo trabajamos con eventos IN
                  .order(:employee_id, :date, :time)

    # Agrupar eventos por empleado y fecha
    events.group_by { |e| [ e.employee_id, e.date ] }.each do |(employee_id, date), employee_events|
      puts "Processing events for employee #{employee_id} on date #{date}"

      first_entry = employee_events.last  # ⬅️ Primer IN del día (último en la lista por el orden DESC)
      last_entry = employee_events.first  # ⬅️ Último IN del día (primero en la lista por el orden DESC)

      entry_datetime = DateTime.parse("#{first_entry.date} #{first_entry.time}")
      exit_datetime = DateTime.parse("#{last_entry.date} #{last_entry.time}")

      # Solo asignamos una salida si hay una diferencia de al menos 5 horas
      if (exit_datetime - entry_datetime) * 24 >= MIN_HOURS_FOR_EXIT
        save_attendance_record(employee_id, entry_datetime, exit_datetime)
      else
        save_attendance_record(employee_id, entry_datetime, nil)
      end

      # Marcar eventos como procesados
      employee_events.each { |event| event.update(processed: true) }
    end
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
