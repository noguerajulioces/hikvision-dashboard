class HomeController < ApplicationController
  def index
    filter = params[:filter] || "yesterday"

    case filter
    when "yesterday"
      range = Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day
    when "week"
      range = Time.zone.today.beginning_of_week..Time.zone.today.end_of_week
    when "month"
      range = Time.zone.today.beginning_of_month..Time.zone.today.end_of_month
    when "year"
      range = Time.zone.today.beginning_of_year..Time.zone.today.end_of_year
    end

    filter_date = Time.zone.today
    @attendance_records = AttendanceRecord.includes(:employee)
                                          .where(entry_time: filter_date.all_day)


    @employees = Employee.active.count
    @attendance_records_count = AttendanceRecord.where(created_at: range).count
    @overtime_records_count = OvertimeRecord.where(created_at: range).count
    @incidents_count = Incident.where(created_at: range).count
  end
end
