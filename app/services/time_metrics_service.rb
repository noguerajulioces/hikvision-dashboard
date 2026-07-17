class TimeMetricsService
  attr_reader :filter

  def initialize(filter = "today")
    @filter = filter
  end

  def calculate
    {
      average_time: calculate_average_time,
      punctuality_rate: calculate_punctuality_rate,
      late_rate: calculate_late_rate,
      absence_rate: calculate_absence_rate
    }
  end

  private

  def date_range
    case filter
    when "week"
      1.week.ago.beginning_of_day..Time.current
    when "month"
      1.month.ago.beginning_of_day..Time.current
    else # today
      Date.today.beginning_of_day..Date.today.end_of_day
    end
  end

  def calculate_average_time
    records = AttendanceRecord.where(entry_time: date_range)
                             .where.not(exit_time: nil)

    return "0h 0m" if records.empty?

    total_minutes = records.sum do |record|
      ((record.exit_time - record.entry_time) / 60).to_i
    end

    avg_minutes = total_minutes / records.count
    hours = avg_minutes / 60
    minutes = avg_minutes % 60

    "#{hours}h #{minutes}m"
  end

  def calculate_punctuality_rate
    # Comparado en Ruby para ser portable: el datetime(..., '+15 minutes') era
    # SQLite-only y el "+ interval" anterior era Postgres-only. El rango es corto
    # (día/semana/mes de una sola empresa), así que la carga en memoria es chica.
    records = AttendanceRecord.includes(:schedule)
                              .where(entry_time: date_range)
                              .select(&:schedule)

    return 0 if records.empty?

    on_time = records.count do |record|
      record.entry_time <= record.schedule.expected_entry_time + 15.minutes
    end

    ((on_time.to_f / records.size) * 100).round
  end

  def calculate_late_rate
    punctuality = calculate_punctuality_rate
    100 - punctuality
  end

  def calculate_absence_rate
    # Asistencias esperadas = por cada horario del rango (grupo + fecha), la
    # cantidad de empleados de ese grupo. Reemplaza la consulta rota sobre
    # "schedules.workday && ARRAY[...]" (Postgres-only y sobre una columna que
    # ya no existe), que siempre fallaba y devolvía un 3% inventado.
    # reorder(nil) quita el ORDER BY date del default_scope: Postgres rechaza
    # ordenar por una columna no agrupada (SQLite lo tolera y no lo detecta).
    schedules_per_group = Schedule.where(date: scheduled_dates).reorder(nil).group(:group_id).count
    return 0 if schedules_per_group.empty?

    employees_per_group = Employee.where(group_id: schedules_per_group.keys).group(:group_id).count
    total_expected = schedules_per_group.sum { |group_id, days| days * employees_per_group.fetch(group_id, 0) }
    return 0 if total_expected.zero?

    actual_attendance = AttendanceRecord.where(entry_time: date_range).count

    absence_count = [ total_expected - actual_attendance, 0 ].max
    ((absence_count.to_f / total_expected) * 100).round
  end

  def scheduled_dates
    date_range.first.to_date..date_range.last.to_date
  end
end
