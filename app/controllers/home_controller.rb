class HomeController < ApplicationController
  def index
    @filter = params[:filter] || 'today'
    
    # Get date range based on filter
    @date_range = case @filter
                  when 'week'
                    1.week.ago.beginning_of_day..Time.current
                  when 'month'
                    1.month.ago.beginning_of_day..Time.current
                  else # today
                    Date.today.beginning_of_day..Date.today.end_of_day
                  end
    
    # Query attendance records directly with date range
    @attendance_records = AttendanceRecord.where(entry_time: @date_range).order(entry_time: :desc).limit(10)
    @attendance_records_count = AttendanceRecord.where(entry_time: @date_range).count
    @employees = Employee.count
    @incidents_count = Incident.where(created_at: @date_range).count
    @exit_records_count = AttendanceRecord.where(exit_time: @date_range).count
    
    # Calculate total hours worked
    @total_hours = AttendanceRecord.where(entry_time: @date_range)
                                  .where.not(exit_time: nil)
                                  .sum('EXTRACT(EPOCH FROM (exit_time - entry_time))/3600')
                                  .round(1)
    
    # Obtener métricas de tiempo usando el servicio
    @time_metrics = TimeMetricsService.new(@filter).calculate
  end
end
