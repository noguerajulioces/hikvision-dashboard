class AttendanceProcessorService
  MIN_HOURS_REQUIRED = 8 # Número mínimo de horas de trabajo

  def initialize(employee_id, start_date = nil, end_date = nil)
    @employee_id = employee_id
    @start_date = start_date || Date.today.beginning_of_month
    @end_date = end_date || Date.today
  end

  def call
    process_attendance
  end

  private

  def process_attendance
    events_by_date = Event.where(employee_id: @employee_id, date: @start_date..@end_date)
                          .where.not(in_out: nil)
                          .order(:date, :time)
                          .group_by(&:date)

    events_by_date.each do |date, events|
      first_entry = events.select { |e| e.in_out == "IN" }.min_by(&:time)
      last_exit = events.select { |e| e.in_out == "OUT" }.max_by(&:time)

      # Si falta un registro, lo marcamos como incompleto
      if first_entry.nil? || last_exit.nil?
        puts "Registro incompleto para el empleado #{@employee_id} en la fecha #{date}"
        next
      end

      # Revisamos si ya existe un registro en `AttendanceRecord`
      attendance = AttendanceRecord.find_or_initialize_by(
        employee_id: @employee_id,
        entry_time: first_entry.time,
        exit_time: last_exit.time
      )

      attendance.processed = true
      attendance.save!
    end
  end
end
