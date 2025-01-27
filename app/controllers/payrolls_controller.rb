class PayrollsController < ApplicationController
  before_action :set_payroll_report, only: [:show, :edit, :update, :destroy]

  def index
    @payroll_reports = Payroll.paginate(page: params[:page])
  end

  def show
  end

  def new
    @payroll_report = Payroll.new
  end

  def edit
  end

  def create
    ActiveRecord::Base.transaction do
      service = WorkHoursService.new(
        params[:employee_id],
        params[:start_date],
        params[:end_date],
        params[:lunch_time] == "1"
      )

      service.process_overtime

      @payroll = Payroll.new(payroll_report_params)

      if @payroll.save
        redirect_to @payroll, notice: 'Reporte de nómina creado exitosamente.'
      else
        raise ActiveRecord::Rollback, 'Error al guardar el reporte de nómina'
      end
    end
  rescue ActiveRecord::Rollback
    flash.now[:alert] = 'Error al crear el reporte de nómina. Operación revertida.'
    render :new, status: :unprocessable_entity
  end

  def update
    if @payroll_report.update(payroll_report_params)
      @payroll_report.calculate_totals
      redirect_to @payroll_report, notice: 'Reporte de nómina actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payroll_report.destroy
    redirect_to payroll_reports_url, notice: 'Reporte de nómina eliminado exitosamente.'
  end

  private

  def set_payroll_report
    @payroll_report = Payroll.find(params[:id])
  end

  def payroll_report_params
    params.permit(:employee_id, :start_date, :end_date, :comments)
  end
end
