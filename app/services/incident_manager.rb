class IncidentManager
  def initialize(employee)
    @employee = employee
  end

  def create_incident(record, issue)
    Incident.create!(
      employee: @employee,
      date: record.entry_time.to_date,
      issue: issue
    )
  end
end
