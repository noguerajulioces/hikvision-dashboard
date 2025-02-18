class AttendanceProcessorService
  MAX_WAIT_HOURS = 12  # Si después de 12 horas no hay OUT, se cierra el turno
  NIGHT_SHIFT_CUTOFF = 6 # Consideramos que un turno nocturno puede terminar hasta las 6 AM

  def initialize
    @processed_count = 0
  end

  def call
    process_attendance
    puts "✅ Procesamiento completado. Registros procesados: #{@processed_count}"
  end

  private

  def process_attendance
    # Filtrar solo eventos NO procesados, ordenados por fecha y hora
    events = Event.where(processed: false)
                  .where.not(in_out: nil)
                  .order(:employee_id, :date, :time)

    # Agrupar eventos por empleado (NO por fecha, para permitir turnos nocturnos)
    events_grouped = events.group_by(&:employee_id)

    events_grouped.each do |employee_id, employee_events|
      current_entry = nil

      employee_events.each_with_index do |event, index|
        if event.in_out == "IN"
          current_entry = event
          next
        end

        if event.in_out == "OUT" && current_entry
          entry_datetime = DateTime.parse("#{current_entry.date} #{current_entry.time}")
          exit_datetime = DateTime.parse("#{event.date} #{event.time}")

          # Si la salida es después de las 6 AM del día siguiente, se considera turno nocturno
          if exit_datetime.hour < NIGHT_SHIFT_CUTOFF
            exit_datetime += 1.day if entry_datetime.day < exit_datetime.day
          end

          # Guardamos el AttendanceRecord
          save_attendance_record(employee_id, entry_datetime, exit_datetime)

          # Marcamos eventos como procesados
          current_entry.update(processed: true)
          event.update(processed: true)
          current_entry = nil
        end
      end

      # Si queda un `IN` sin `OUT`, lo cerramos después de `MAX_WAIT_HOURS`
      if current_entry
        entry_datetime = DateTime.parse("#{current_entry.date} #{current_entry.time}")
        exit_datetime = entry_datetime + MAX_WAIT_HOURS.hours

        save_attendance_record(employee_id, entry_datetime, exit_datetime)
        current_entry.update(processed: true)
      end
    end
  end

  def save_attendance_record(employee_id, entry_datetime, exit_datetime)
    attendance = AttendanceRecord.find_or_initialize_by(
      employee_id: employee_id,
      entry_time: entry_datetime
    )

    attendance.device_id = Device.first.id
    attendance.exit_time = exit_datetime

    if attendance.save
      @processed_count += 1
      puts "✅ Registro de asistencia guardado para empleado #{employee_id}: Entrada #{entry_datetime}, Salida #{exit_datetime}"
    else
      puts "⚠️ Error guardando `AttendanceRecord`: #{attendance.errors.full_messages.join(', ')}"
    end
  end
end
