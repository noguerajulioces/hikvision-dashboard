# AttendanceProcessorService
# 
# This service processes unprocessed events from the Event model and creates
# attendance records by grouping events by employee and date.
# It identifies entry and exit times for each employee on each day.
class AttendanceProcessorService
  def initialize
    @processed_count = 0
  end

  # Main method to start the processing of events
  # @return [Integer] The number of attendance records created
  def call
    puts "🔄 Iniciando procesamiento de eventos agrupados por día..."
    process_grouped_events
    puts "✅ Procesamiento completo. Registros creados: #{@processed_count}"
  end

  private

  # Groups unprocessed events by employee and date, then processes each group
  # @return [void]
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

  # Creates an attendance record for a specific employee on a specific day
  # @param employee_id [Integer] The ID of the employee
  # @param events [Array<Event>] The events for the employee on the day
  # @return [void]
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

  # Builds a DateTime object from an event's date and time
  # @param event [Event] The event containing date and time
  # @return [DateTime] The combined date and time
  def build_datetime(event)
    DateTime.parse("#{event.date} #{event.time}")
  end

  # Gets the ID of the first device in the system
  # @return [Integer, nil] The ID of the first device or nil if no devices exist
  def first_device_id
    Device.first&.id
  end

  # Marks all events as processed
  # @param events [Array<Event>] The events to mark as processed
  # @return [void]
  def mark_events_as_processed(events)
    events.each { |e| e.update(processed: true) }
  end

  # Logs a successful attendance record creation
  # @param employee_id [Integer] The ID of the employee
  # @param entry_time [DateTime] The entry time
  # @param exit_time [DateTime] The exit time
  # @return [void]
  def log_success(employee_id, entry_time, exit_time)
    puts "✅ Guardado: #{employee_id} - Entrada: #{entry_time}, Salida: #{exit_time}"
  end

  # Logs an error when an attendance record fails to save
  # @param employee_id [Integer] The ID of the employee
  # @param attendance [AttendanceRecord] The attendance record that failed to save
  # @return [void]
  def log_error(employee_id, attendance)
    puts "⚠️ Error para #{employee_id}: #{attendance.errors.full_messages.join(', ')}"
  end
end