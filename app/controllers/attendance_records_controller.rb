class AttendanceRecordsController < ApplicationController
  before_action :set_attendance_record, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = AttendanceRecord.ransack(params[:q])
    @attendance_records = @q.result.includes(:employee).paginate(page: params[:page])
  end

  def show
  end

  def new
    @attendance_record = AttendanceRecord.new
  end

  def create
    @attendance_record = AttendanceRecord.new(attendance_record_params)
    if @attendance_record.save
      redirect_to attendance_records_path, notice: "Registro de asistencia creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @attendance_record.update(attendance_record_params)
      redirect_to attendance_records_path, notice: "Registro de asistencia actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attendance_record.destroy
    redirect_to attendance_records_path, notice: "Registro de asistencia eliminado exitosamente."
  end

  private

  def set_attendance_record
    @attendance_record = AttendanceRecord.find(params[:id])
  end

  def attendance_record_params
    params.require(:attendance_record).permit(:employee_id, :entry_time, :exit_time, :device_id)
  end
end
