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

    # los unproceesses debo pasar a true en el rango de fechas
    # generar los incidents en caso que haya
    # debo de crear los overtime
    # 

    byebug
    
    @payroll_report = Payroll.new(payroll_report_params)

    if @payroll_report.save
      @payroll_report.calculate_totals
      redirect_to @payroll_report, notice: 'Reporte de nómina creado exitosamente.'
    else
      flash.now[:alert] = 'Error al crear el reporte de nómina.'
      render :new, status: :unprocessable_entity
    end
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
