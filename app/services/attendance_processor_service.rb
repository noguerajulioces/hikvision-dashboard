class AttendanceProcessorService
  MIN_HOURS_REQUIRED = 8 # Horas mínimas requeridas por jornada laboral

  def initialize
    @processed_count = 0
  end

  def call
    process_attendance
    puts "✅ Procesamiento completado. Registros procesados: #{@processed_count}"
  end

  private

  def process_attendance
    # Filtrar solo eventos NO procesados
    events = Event.where(processed: false)
                  .where.not(in_out: nil)
                  .order(:date, :time)

    # Agrupar eventos por empleado y fecha
    events_grouped = events.group_by { |e| [e.employee_id, e.date] }

    events_grouped.each do |(employee_id, date), events|
      first_entry = events.select { |e| e.in_out == "IN" }.min_by(&:time)
      last_exit = events.select { |e| e.in_out == "OUT" }.max_by(&:time)

      # Validar si hay ambos registros
      if first_entry.nil? || last_exit.nil?
        puts "⚠️ Registro incompleto para empleado #{employee_id} el #{date}"
        next
      end

      # Convertimos `date` y `time` en `datetime`
      entry_datetime = DateTime.parse("#{first_entry.date} #{first_entry.time}")
      exit_datetime = DateTime.parse("#{last_exit.date} #{last_exit.time}")

      # Buscamos o creamos un `AttendanceRecord`
      attendance = AttendanceRecord.find_or_initialize_by(
        employee_id: employee_id,
        entry_time: entry_datetime
      )

      attendance.exit_time = exit_datetime
      #attendance.processed = true

      if attendance.save
        # Marcar eventos como procesados
        events.each { |event| event.update(processed: true) }
        @processed_count += 1
        puts "✅ Registro de asistencia guardado para empleado #{employee_id} el #{date}: Entrada #{entry_datetime}, Salida #{exit_datetime}"
      else
        puts "⚠️ Error guardando `AttendanceRecord`: #{attendance.errors.full_messages.join(', ')}"
      end
    end
  end
end
