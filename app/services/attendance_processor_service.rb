class AttendanceProcessorService
  def initialize
    @processed_count = 0
  end

  def call
    puts "🔄 Iniciando procesamiento de eventos agrupados por día..."
    process_grouped_events
    puts "✅ Procesamiento completo. Registros creados: #{@processed_count}"
  end

  private

  def process_grouped_events
    grouped_events = Event
                      .where(processed: false)
                      .order(:employee_id, :date, :time)
                      .group_by(&:employee_id)

    grouped_events.each do |employee_id, events|
      events.group_by(&:date).each do |date, daily_events|
        create_attendance_for_day(employee_id, daily_events)
      end
    end
  end

  def create_attendance_for_day(employee_id, events)
    sorted_events = events.sort_by { |e| e.time }

    entry_time = build_datetime(sorted_events.first)
    exit_time = sorted_events.size > 1 ? build_datetime(sorted_events.last) : nil

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
    puts "✅ Guardado: #{employee_id} - Entrada: #{entry_time}, Salida: #{exit_time || 'N/A'}"
  end

  def log_error(employee_id, attendance)
    puts "⚠️ Error para #{employee_id}: #{attendance.errors.full_messages.join(', ')}"
  end
end
