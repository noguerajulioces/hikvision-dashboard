class ReportsController < ApplicationController
  def index
    @reports = AttendanceRecord.all + OvertimeRecord.all + Incident.all + Absence.all
  end

  def show
    employee = Employee.find(params[:id])
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date

    @report = AttendanceReportService.new(employee, start_date, end_date).generate_report
  end

  def employee_report
    employee_id = params[:employee_id]
    start_date = params[:start_date]
    end_date = params[:end_date]

    if employee_id.present? && start_date.present? && end_date.present?
      @employee = Employee.find(employee_id)
      @unprocessed_records = @employee.unprocessed_attendance_records(start_date.to_date, end_date.to_date)
    else
      @unprocessed_records = []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "employee-list",
          partial: "reports/employee_report",
          locals: { unprocessed_records: @unprocessed_records }
        )
      end
      format.html { redirect_to new_report_path }
    end
  end

  private

  def calculate_compensation(worked_hours, overtime_hours)
    hourly_rate = 10 # Tarifa por hora
    overtime_rate = 15 # Tarifa por hora extra
    (worked_hours * hourly_rate) + (overtime_hours * overtime_rate)
  end

  def render_pdf(employee, records)
    pdf = Prawn::Document.new
    pdf.text "Reporte de Horas para #{employee.full_name}"
    pdf.text "Horas trabajadas: #{@worked_hours}"
    pdf.text "Horas extras: #{@overtime_hours}"
    pdf.text "Compensación total: #{@total_compensation}"
    send_data pdf.render, filename: "reporte_#{employee.full_name}.pdf", type: "application/pdf"
  end

  def render_xlsx(employee, records)
    workbook = RubyXL::Workbook.new
    sheet = workbook[0]
    sheet.add_cell(0, 0, "Reporte de Horas para #{employee.full_name}")
    sheet.add_cell(1, 0, "Horas trabajadas")
    sheet.add_cell(1, 1, @worked_hours)
    sheet.add_cell(2, 0, "Horas extras")
    sheet.add_cell(2, 1, @overtime_hours)
    sheet.add_cell(3, 0, "Compensación total")
    sheet.add_cell(3, 1, @total_compensation)
    send_data workbook.stream.string, filename: "reporte_#{employee.full_name}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end
