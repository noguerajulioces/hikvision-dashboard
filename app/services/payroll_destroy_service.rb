class PayrollDestroyService
  def initialize(payroll)
    @payroll = payroll
  end

  def call
    ActiveRecord::Base.transaction do
      delete_related_records
      @payroll.destroy!
    end
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::Rollback => e
    Rails.logger.error("Error al eliminar nómina: #{e.message}")
    false
  end

  private

  def delete_related_records
    delete_overtime_records
    delete_incidents
    unprocess_attendance_records
  end

  def delete_overtime_records
    overtime_records_ids = @payroll.overtime_records.pluck(:id)
    OvertimeRecord.where(id: overtime_records_ids).destroy_all
  end

  def delete_incidents
    incidents_ids = @payroll.incidents.pluck(:id)
    Incident.where(id: incidents_ids).destroy_all
  end

  def unprocess_attendance_records
    attendance_records_ids = @payroll.attendance_records.pluck(:id)
    AttendanceRecord.where(id: attendance_records_ids).update_all(processed: false)
  end
end
