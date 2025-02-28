class IncidentManager
  def initialize(employee)
    @employee = employee
  end

  def create_incident(record, issue)
    date = if record.is_a?(AttendanceRecord)
      record.entry_time&.to_date
    elsif record.is_a?(Schedule)
      record.date
    else
      Date.today
    end

    Incident.create!(
      employee: @employee,
      date: date,
      issue: issue
    )
  end
end
