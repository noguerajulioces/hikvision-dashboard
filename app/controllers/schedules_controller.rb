class SchedulesController < ApplicationController
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    @schedules = Schedule.page(params[:page])
  end

  def show
  end

  def new
    @schedule = Schedule.new
  end

  def edit
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.save
      redirect_to schedules_path, notice: "El horario fue creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: "El horario fue actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_url, notice: "El horario fue eliminado exitosamente."
  end

  def duplicate
    @original_schedule = Schedule.find(params[:id])

    # Calcula la nueva fecha
    new_date = @original_schedule.date + 1.day

    # Verifica si ya existe un registro con el mismo group_id y date
    if Schedule.exists?(group_id: @original_schedule.group_id, date: new_date)
      redirect_to schedules_path, alert: "Ya existe un horario para esta fecha y función."
      return
    end

    # Si no existe, proceder a duplicar
    @new_schedule = @original_schedule.dup
    @new_schedule.date = new_date
    @new_schedule.expected_entry_time = @original_schedule.expected_entry_time + 1.day
    @new_schedule.expected_exit_time = @original_schedule.expected_exit_time + 1.day

    if @new_schedule.save
      redirect_to schedules_path, notice: "Horario duplicado exitosamente."
    else
      redirect_to schedules_path, alert: "Error al duplicar el horario."
    end
  end

  private
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    def schedule_params
      params.require(:schedule).permit(:date, :expected_entry_time, :expected_exit_time, :group_id, :include_lunch)
    end
end
