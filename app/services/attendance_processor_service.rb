class AttendanceProcessorService
  def initialize
    @processed_count = 0
  end

  def call
    puts "🔄 Iniciando procesamiento de eventos..."
    process_events
    puts "✅ Procesamiento completo. Registros creados: #{@processed_count}"
  end

  private

  def process_events
    Event.find_each do |event|
      create_attendance_from_event(event)
    end
  end

  def create_attendance_from_event(event)
    attendance = find_or_initialize_attendance(event)
    attendance.device_id = first_device_id

    if attendance.save
      @processed_count += 1
      log_success(event, attendance)
    else
      log_error(event, attendance)
    end
  end

  def find_or_initialize_attendance(event)
    AttendanceRecord.find_or_initialize_by(
      employee_id: event.employee_id,
      entry_time: build_datetime(event)
    )
  end

  def build_datetime(event)
    DateTime.parse("#{event.date} #{event.time}")
  end

  def first_device_id
    Device.first&.id
  end

  def log_success(event, attendance)
    puts "✅ Creado para empleado #{event.employee_id}: #{attendance.entry_time}"
  end

  def log_error(event, attendance)
    puts "⚠️ Error para #{event.employee_id}: #{attendance.errors.full_messages.join(', ')}"
  end
end
