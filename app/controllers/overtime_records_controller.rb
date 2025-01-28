class OvertimeRecordsController < ApplicationController
  before_action :set_overtime_record, only: [ :show, :edit, :update, :destroy ]

  def index
    @overtime_records = OvertimeRecord.page(params[:page])
  end

  def show
  end

  def new
    @overtime_record = OvertimeRecord.new
  end

  def create
    @overtime_record = OvertimeRecord.new(overtime_record_params)
    if @overtime_record.save
      redirect_to @overtime_record, notice: "Registro de horas extras creado exitosamente."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @overtime_record.update(overtime_record_params)
      redirect_to @overtime_record, notice: "Registro de horas extras actualizado exitosamente."
    else
      render :edit
    end
  end

  def destroy
    @overtime_record.destroy
    redirect_to overtime_records_url, notice: "Registro de horas extras eliminado exitosamente."
  end

  private

  def set_overtime_record
    @overtime_record = OvertimeRecord.find(params[:id])
  end

  def overtime_record_params
    params.require(:overtime_record).permit(:date, :hours_worked, :compensation, :employee_id)
  end
end
