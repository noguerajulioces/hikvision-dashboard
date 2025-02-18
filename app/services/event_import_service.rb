require "csv"

class EventImportService
  def initialize(file_path)
    @file_path = file_path
    @imported_count = 0
    @errors = []
  end

  def call
    import_events
    process_attendance_records
    summary
  end

  private

  def import_events
    CSV.foreach(@file_path, headers: true, encoding: "bom|utf-8") do |row|
      process_row(row)
    end
  rescue StandardError => e
    @errors << "⚠️ Error general en la importación: #{e.message}"
  end

  def process_row(row)
    employee = find_or_create_employee(row["sJobNo"])

    event = Event.new(
      s_name: row["sName"],
      s_job_no: row["sJobNo"],
      s_card: row["sCard"],
      date: row["Date"],
      time: row["Time"],
      in_out: row["IN/OUT"],
      read_id: row["ReadID"],
      event_main_code: row["EventMainCode"],
      event_sub_code: row["EventSubCode"],
      attendance_status: row["AttendanceStatus"],
      wear_mask: row["WearMask"],
      serial_no: row["SerialNo"],
      employee: employee
    )

    if event.save
      @imported_count += 1
    else
      @errors << "⚠️ Error en fila #{row['sJobNo']}: #{event.errors.full_messages.join(', ')}"
    end
  end

  def find_or_create_employee(document_number)
    return nil unless document_number.present?

    cleaned_document = document_number.delete_prefix("'")
    Employee.find_or_create_by!(document_number: cleaned_document)
  rescue ActiveRecord::RecordInvalid => e
    @errors << "⚠️ Error al crear empleado con documento #{document_number}: #{e.message}"
    nil
  end

  def process_attendance_records
    puts "🔄 Procesando registros de asistencia..."
    AttendanceProcessorService.new.call
  end

  def summary
    {
      total_imported: @imported_count,
      errors: @errors
    }
  end
end
