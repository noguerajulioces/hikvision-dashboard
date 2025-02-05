class HomeController < ApplicationController
  def index
    @employees = Employee.active.count
    @attendance_records = AttendanceRecord.all
    @overtime_records = OvertimeRecord.all
    @incidents = Incident.all
  end
end
