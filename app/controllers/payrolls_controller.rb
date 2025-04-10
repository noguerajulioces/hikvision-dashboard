class PayrollsController < ApplicationController
  before_action :set_payroll, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Payroll.ransack(params[:q])
    @payrolls = @q.result.includes(:employee).paginate(page: params[:page])
  end

  def show
    @not_worked_days = @payroll.incidents
                         .where("issue LIKE ?", "%No se presentó%")
                         .count

    respond_to do |format|
      format.html # Renderiza la vista normal en HTML
      format.pdf do
        render pdf: "tarjeta_de_horario",
               template: "payrolls/show",
               layout: "pdf",
               disposition: "inline",
               page_width: '216mm',
               page_height: '178mm',
               margin: {
                 top: '5mm',
                 bottom: '5mm',
                 left: '10mm',
                 right: '10mm'
               }
      end
    end
  end

  def new
    @payroll = Payroll.new
  end

  def edit
  end

  def create
    ActiveRecord::Base.transaction do
      service = WorkHoursService.new(
        params[:employee_id],
        params[:start_date],
        params[:end_date],
        params[:lunch_time]
      )

      @payroll = service.process_overtime

      @payroll.calculate_totals(AppSetting&.lunch_hours)

      if @payroll.save
        redirect_to @payroll, notice: "Reporte de nómina creado exitosamente."
      else
        raise ActiveRecord::Rollback, "Error al guardar el reporte de nómina"
      end
    end
  rescue ActiveRecord::Rollback
    flash.now[:alert] = "Error al crear el reporte de nómina. Operación revertida."
    render :new, status: :unprocessable_entity
  end

  def update
    if @payroll.update(payroll_params)
      @payroll.calculate_totals
      redirect_to @payroll, notice: "Reporte de nómina actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service = PayrollDestroyService.new(@payroll)

    if service.call
      redirect_to payrolls_url, notice: "Reporte de nómina eliminado exitosamente."
    else
      flash.now[:alert] = "Error al eliminar el reporte de nómina. Operación revertida."
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  def payroll_params
    params.permit(:employee_id, :start_date, :end_date, :comments)
  end

  def link_related_records(payroll)
    attendance_records = AttendanceRecord.where(employee_id: payroll.employee_id, entry_time: payroll.start_date.beginning_of_day..payroll.end_date.end_of_day)
    overtime_records = OvertimeRecord.where(employee_id: payroll.employee_id, date: payroll.start_date..payroll.end_date)
    incidents = Incident.where(employee_id: payroll.employee_id, date: payroll.start_date..payroll.end_date)

    (attendance_records + overtime_records + incidents).each do |record|
      PayrollEntry.create!(payroll: payroll, recordable: record)
    end
  end
end
