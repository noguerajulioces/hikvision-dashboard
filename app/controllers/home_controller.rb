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
    
    # Calculate attendance rate
    calculate_attendance_rate
    
    # Obtener métricas de tiempo usando el servicio
    @time_metrics = TimeMetricsService.new(@filter).calculate
  end
  
  private
  
  def calculate_attendance_rate
    # Get unique employees who were scheduled during this period
    scheduled_employees = Employee.joins(:schedule)
                                 .where("schedules.workday && ARRAY[?]::integer[]", workdays_in_range)
                                 .distinct.count
    
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
  
  def workdays_in_range
    case @filter
    when 'week'
      (Date.today.beginning_of_week..Date.today).map(&:wday)
    when 'month'
      (Date.today.beginning_of_month..Date.today).map(&:wday).uniq
    else
      [Date.today.wday]
    end
  end
end
