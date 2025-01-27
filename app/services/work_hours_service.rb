# Que necesito en mi services.
# Generar reporte de pago por usuario, por fecha de inicio a fecha de fin a partir del attendanceRecord.
# 

class WorkHoursService
  def initialize(employee_id, start_date, end_date, lunch_time = false)
    @employee = Employee.find(employee_id)
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @lunch_time = lunch_time
  end

  def process_overtime
    records = @employee.unprocessed_attendance_records(@start_date, @end_date)
    
    records.each do |record|
      if record.exit_time.nil?
        Incident.create!(
          employee: @employee,
          date: record.entry_time.to_date,
          issue: "No se registró hora de salida"
        )
      else
        hours = calculate_overtime_hours(record)
        
        if hours > 0
          OvertimeRecord.create!(
            employee: @employee,
            date: record.entry_time.to_date,
            hours: hours
          )
        end
      end
      
      record.update(processed: true)
    end
  end

  private

  def calculate_overtime_hours(record)
    total_hours = (record.exit_time - record.entry_time) / 3600.0
    
    # Restar hora de almuerzo si corresponde
    if @lunch_time && total_hours > 4
      total_hours -= 1 
    end

    # Las horas extras son las que exceden 8 horas
    [total_hours - 8, 0].max
  end
end