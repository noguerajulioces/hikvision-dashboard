class PayrollsController < ApplicationController
  before_action :set_payroll, only: [:show, :edit, :update, :destroy]

  def index
    @payrolls = Payroll.paginate(page: params[:page])
  end

  def show
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
        params[:lunch_time] == "1"
      )

      service.process_overtime

      @payroll = Payroll.new(payroll_params)

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
    if @payroll.update(payroll_params)
      @payroll.calculate_totals
      redirect_to @payroll, notice: 'Reporte de nómina actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payroll.destroy
    redirect_to payrolls_url, notice: 'Reporte de nómina eliminado exitosamente.'
  end

  private

  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  def payroll_params
    params.permit(:employee_id, :start_date, :end_date, :comments)
  end
end
