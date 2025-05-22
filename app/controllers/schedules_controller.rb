class SchedulesController < ApplicationController
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Schedule.ransack(params[:q])
    @schedules = @q.result.paginate(page: params[:page])
  end

  def show
  end

  def new
    @group = Group.new
    @group.schedules.build if params[:group].blank?
  end

  def edit
    @group = @schedule.group
  end


  def create
    @group = Group.find(params[:group][:group_id])
    has_errors = false

    params[:group][:schedules_attributes].each do |_key, schedule_params|
      next if schedule_params["_destroy"] == "1"

      entry_time = schedule_params[:expected_entry_time]
      exit_time  = schedule_params[:expected_exit_time]
      date       = entry_time.to_date rescue nil

      if Schedule.exists?(group_id: @group.id, date: date)
        has_errors = true
        @group.errors.add(:base, "Ya existe un horario para la fecha #{date.strftime('%d/%m/%Y')} en esta función.")
        next
      end

      schedule = Schedule.new(
        group_id: @group.id,
        date: date,
        expected_entry_time: entry_time,
        expected_exit_time: exit_time,
        include_lunch: schedule_params[:include_lunch]
      )

      unless schedule.save
        has_errors = true
        @group.errors.add(:base, schedule.errors.full_messages.to_sentence)
      end
    end

    if has_errors
      render :new, status: :unprocessable_entity
    else
      redirect_to schedules_path, notice: "Horarios guardados exitosamente."
    end
  end

  def update
    if @schedule.update(schedule_direct_params)
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
      params.require(:group).permit(
        :group_id,
        schedules_attributes: [
          :expected_entry_time,
          :expected_exit_time,
          :include_lunch,
          :_destroy
        ]
      )
    end

    def schedule_direct_params
      params.require(:schedule).permit(
        :expected_entry_time,
        :expected_exit_time,
        :include_lunch,
        :group_id
      )
    end
end
