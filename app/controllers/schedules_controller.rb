class SchedulesController < ApplicationController
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    @schedules = Schedule.all
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

  private
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    def schedule_params
      params.require(:schedule).permit(:date, :expected_entry_time, :expected_exit_time, :group_id)
    end
end
