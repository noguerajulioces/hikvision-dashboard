class HomeController < ApplicationController
  def index
    @filter = params[:filter] || "today"

    # Get date range based on filter
    @date_range = case @filter
    when "week"
                    1.week.ago.beginning_of_day..Time.current
    when "month"
                    1.month.ago.beginning_of_day..Time.current
    else # today
                    Date.today.beginning_of_day..Date.today.end_of_day
    end

    # Query attendance records directly with date range
    @attendance_records = AttendanceRecord.where(entry_time: @date_range)
                                          .includes(employee: :group)
                                          .order(entry_time: :desc).limit(10)
    @attendance_records_count = AttendanceRecord.where(entry_time: @date_range).count
    @employees = Employee.count
    @incidents_count = Incident.where(created_at: @date_range).count
    @exit_records_count = AttendanceRecord.where(exit_time: @date_range).count

    # Calculate total hours worked. Computed in Ruby so it is database-agnostic
    # (the previous EXTRACT(EPOCH FROM ...) is Postgres-only and breaks on SQLite).
    # The range is a single day/week/month for one company, so the row count is small.
    @total_hours = AttendanceRecord.where(entry_time: @date_range)
                                  .where.not(exit_time: nil)
                                  .sum { |record| (record.exit_time - record.entry_time) / 3600.0 }
                                  .round(1)

    # Calculate attendance rate
    calculate_attendance_rate

    # Obtener métricas de tiempo usando el servicio
    @time_metrics = TimeMetricsService.new(@filter).calculate
  end

  private

  def calculate_attendance_rate
    # Empleados con horario en el período: los de grupos que tienen un Schedule
    # fechado dentro del rango. Reemplaza la consulta rota sobre
    # "schedules.workday && ARRAY[...]" (Postgres-only y sobre una columna que ya
    # no existe), que siempre fallaba y dejaba la tasa en 0.
    scheduled_dates = @date_range.first.to_date..@date_range.last.to_date
    scheduled_employees = Employee.where(
      group_id: Schedule.where(date: scheduled_dates).select(:group_id)
    ).count

    # Get unique employees who actually attended
    attending_employees = Employee.joins(:attendance_records)
                                 .where(attendance_records: { entry_time: @date_range })
                                 .distinct.count

    # Calculate attendance rate
    @attendance_rate = scheduled_employees > 0 ?
                      ((attending_employees.to_f / scheduled_employees) * 100).round :
                      100
  rescue => e
    # Fallback if there's an error
    @attendance_rate = 0
    Rails.logger.error("Error calculating attendance rate: #{e.message}")
  end
end
